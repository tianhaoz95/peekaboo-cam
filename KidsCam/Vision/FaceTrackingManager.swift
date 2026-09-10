import Foundation
import UIKit
import Vision
import CoreMedia
import ImageIO
import Combine

public final class FaceTrackingManager: ObservableObject {
    public static let shared = FaceTrackingManager()

    // MARK: - Published State
    @Published public var activeFilter: FaceEmojiType? = nil
    @Published public var isFaceDetected: Bool = false
    @Published public var normalizedFaceRect: CGRect = CGRect(x: 0.25, y: 0.15, width: 0.5, height: 0.5)
    @Published public var eyesCenterNormalized: CGPoint? = nil
    @Published public var foreheadCenterNormalized: CGPoint? = nil

    private let visionQueue = DispatchQueue(label: "com.hejitech.kidscam.visionQueue", qos: .userInteractive)
    private var isProcessingFrame = false

    // Exponential smoothing factor (0.0 = no update, 1.0 = instant snap)
    private let smoothingAlpha: CGFloat = 0.38

    private init() {}

    // MARK: - Configuration
    public func setActiveFilter(_ filter: FaceEmojiType?) {
        if Thread.isMainThread {
            self.activeFilter = filter
        } else {
            DispatchQueue.main.async {
                self.activeFilter = filter
            }
        }
    }

    public func clearFilter() {
        if Thread.isMainThread {
            self.activeFilter = nil
        } else {
            DispatchQueue.main.async {
                self.activeFilter = nil
            }
        }
    }

    // MARK: - Frame Processing (CMSampleBuffer)
    public func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation = .leftMirrored) {
        guard activeFilter != nil else { return }
        guard !isProcessingFrame else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessingFrame = true
        visionQueue.async { [weak self] in
            guard let self = self else { return }
            defer { self.isProcessingFrame = false }

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            self.performFaceLandmarksRequest(handler: requestHandler)
        }
    }

    // MARK: - Frame Processing (CGImage / UIImage)
    public func processCGImage(_ cgImage: CGImage, orientation: CGImagePropertyOrientation = .up) {
        guard activeFilter != nil else { return }
        guard !isProcessingFrame else { return }

        isProcessingFrame = true
        visionQueue.async { [weak self] in
            guard let self = self else { return }
            defer { self.isProcessingFrame = false }

            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            self.performFaceLandmarksRequest(handler: requestHandler)
        }
    }

    public func processUIImage(_ image: UIImage) {
        guard let cg = image.cgImage else { return }
        let orientation: CGImagePropertyOrientation
        switch image.imageOrientation {
        case .up: orientation = .up
        case .down: orientation = .down
        case .left: orientation = .left
        case .right: orientation = .right
        case .upMirrored: orientation = .upMirrored
        case .downMirrored: orientation = .downMirrored
        case .leftMirrored: orientation = .leftMirrored
        case .rightMirrored: orientation = .rightMirrored
        @unknown default: orientation = .up
        }
        processCGImage(cg, orientation: orientation)
    }

    // MARK: - Native Vision Detection
    private func performFaceLandmarksRequest(handler: VNImageRequestHandler) {
        let request = VNDetectFaceLandmarksRequest { [weak self] (req, error) in
            guard let self = self else { return }
            if let results = req.results as? [VNFaceObservation], let face = results.first {
                self.updateDetectedFace(face)
            } else {
                DispatchQueue.main.async {
                    self.isFaceDetected = false
                }
            }
        }

        do {
            try handler.perform([request])
        } catch {
            print("[FaceTrackingManager] Vision error: \(error)")
        }
    }

    // MARK: - Face Observation Handling & Smoothing
    private func updateDetectedFace(_ face: VNFaceObservation) {
        // Vision coordinates: origin is bottom-left (0,0), size is (1,1)
        // Convert to UIKit/SwiftUI coordinates: origin is top-left (0,0)
        let visionBox = face.boundingBox
        let targetX = visionBox.origin.x
        let targetY = 1.0 - (visionBox.origin.y + visionBox.size.height)
        let targetWidth = visionBox.size.width
        let targetHeight = visionBox.size.height
        let targetRect = CGRect(x: targetX, y: targetY, width: targetWidth, height: targetHeight)

        // Extract landmarks if available (eyes & forehead)
        var eyesCenter: CGPoint? = nil
        var foreheadCenter: CGPoint? = nil

        if let landmarks = face.landmarks {
            if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
                let leftPoints = leftEye.normalizedPoints
                let rightPoints = rightEye.normalizedPoints
                if !leftPoints.isEmpty && !rightPoints.isEmpty {
                    // Average points in face bounding box
                    let avgLeftX = leftPoints.map { $0.x }.reduce(0, +) / CGFloat(leftPoints.count)
                    let avgLeftY = leftPoints.map { $0.y }.reduce(0, +) / CGFloat(leftPoints.count)
                    let avgRightX = rightPoints.map { $0.x }.reduce(0, +) / CGFloat(rightPoints.count)
                    let avgRightY = rightPoints.map { $0.y }.reduce(0, +) / CGFloat(rightPoints.count)

                    let midEyeVisionX = visionBox.origin.x + ((avgLeftX + avgRightX) / 2.0) * visionBox.size.width
                    let midEyeVisionY = visionBox.origin.y + ((avgLeftY + avgRightY) / 2.0) * visionBox.size.height

                    eyesCenter = CGPoint(x: midEyeVisionX, y: 1.0 - midEyeVisionY)
                }
            }

            if let contour = landmarks.faceContour {
                let pts = contour.normalizedPoints
                if !pts.isEmpty {
                    // Top-most contour point
                    let topContourY = pts.map { $0.y }.max() ?? 1.0
                    let foreheadVisionX = visionBox.origin.x + (visionBox.size.width * 0.5)
                    let foreheadVisionY = visionBox.origin.y + (topContourY * visionBox.size.height)
                    foreheadCenter = CGPoint(x: foreheadVisionX, y: 1.0 - foreheadVisionY)
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isFaceDetected = true

            // Exponential smoothing to prevent jitter
            let current = self.normalizedFaceRect
            let smoothedX = current.origin.x + (targetRect.origin.x - current.origin.x) * self.smoothingAlpha
            let smoothedY = current.origin.y + (targetRect.origin.y - current.origin.y) * self.smoothingAlpha
            let smoothedW = current.size.width + (targetRect.size.width - current.size.width) * self.smoothingAlpha
            let smoothedH = current.size.height + (targetRect.size.height - current.size.height) * self.smoothingAlpha

            self.normalizedFaceRect = CGRect(x: smoothedX, y: smoothedY, width: smoothedW, height: smoothedH)
            self.eyesCenterNormalized = eyesCenter ?? CGPoint(x: smoothedX + smoothedW * 0.5, y: smoothedY + smoothedH * 0.42)
            self.foreheadCenterNormalized = foreheadCenter ?? CGPoint(x: smoothedX + smoothedW * 0.5, y: smoothedY + smoothedH * 0.15)
        }
    }

    // MARK: - UI Coordinate Conversion
    public func anchorPoint(for anchor: FaceAnchorPosition, in containerSize: CGSize) -> CGPoint {
        let rect = normalizedFaceRect

        switch anchor {
        case .forehead:
            let pt = foreheadCenterNormalized ?? CGPoint(x: rect.midX, y: rect.origin.y + rect.size.height * 0.15)
            return CGPoint(x: pt.x * containerSize.width, y: pt.y * containerSize.height)

        case .eyes:
            let pt = eyesCenterNormalized ?? CGPoint(x: rect.midX, y: rect.origin.y + rect.size.height * 0.42)
            return CGPoint(x: pt.x * containerSize.width, y: pt.y * containerSize.height)

        case .head:
            return CGPoint(x: rect.midX * containerSize.width, y: (rect.origin.y + rect.size.height * 0.45) * containerSize.height)
        }
    }

    public func emojiSize(in containerSize: CGSize, for filter: FaceEmojiType) -> CGFloat {
        let faceWidth = normalizedFaceRect.size.width * containerSize.width

        switch filter.anchorPosition {
        case .forehead:
            // Crowns and bunny ears should be nicely sized on the head
            return max(faceWidth * 0.9, 64)
        case .eyes:
            // Sunglasses sized to span across both eyes
            return max(faceWidth * 0.85, 54)
        case .head:
            // Animal mask slightly larger than face
            return max(faceWidth * 1.15, 80)
        }
    }
}
