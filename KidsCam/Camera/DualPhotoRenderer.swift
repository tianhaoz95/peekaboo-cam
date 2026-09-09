import Foundation
import UIKit
import CoreGraphics

public final class DualPhotoRenderer {

    public static func composeDualPhoto(
        backImage: UIImage,
        frontImage: UIImage,
        layout: CameraLayoutMode,
        primaryPosition: ActiveCameraPosition,
        sticker: String?
    ) -> UIImage {
        let size = CGSize(width: 1200, height: 1600)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            let cg = ctx.cgContext

            let mainImage = (primaryPosition == .back) ? backImage : frontImage
            let pipImage = (primaryPosition == .back) ? frontImage : backImage

            // Draw main full image
            mainImage.draw(in: CGRect(origin: .zero, size: size))

            // Draw PiP overlay in top right
            let pipWidth: CGFloat = 360
            let pipHeight: CGFloat = 480
            let pipRect = CGRect(x: size.width - pipWidth - 36, y: 50, width: pipWidth, height: pipHeight)

            // Shadow & rounded border
            cg.saveGState()
            cg.setShadow(offset: CGSize(width: 0, height: 8), blur: 16, color: UIColor.black.withAlphaComponent(0.35).cgColor)
            let clipPath = UIBezierPath(roundedRect: pipRect, cornerRadius: 28)
            UIColor.white.setStroke()
            clipPath.lineWidth = 10
            clipPath.stroke()
            clipPath.addClip()
            pipImage.draw(in: pipRect)
            cg.restoreGState()

            // Border outline
            let borderPath = UIBezierPath(roundedRect: pipRect, cornerRadius: 28)
            UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).setStroke()
            borderPath.lineWidth = 6
            borderPath.stroke()

            // Draw sticker if present
            if let st = sticker {
                let font = UIFont.systemFont(ofSize: 140)
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                let stStr = NSString(string: st)
                stStr.draw(at: CGPoint(x: 50, y: size.height - 240), withAttributes: attrs)
            }

            // Watermark ribbon at bottom
            drawWatermark(size: size)
        }
    }

    private static func drawWatermark(size: CGSize) {
        let ribbonHeight: CGFloat = 80
        let ribbonRect = CGRect(x: 0, y: size.height - ribbonHeight, width: size.width, height: ribbonHeight)

        let colors = [UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.clear.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let grad = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [1.0, 0.0]) {
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: size.height), end: CGPoint(x: 0, y: size.height - ribbonHeight), options: [])
        }

        let title = "📸 ToddlerCam Dual Shot"
        let font = UIFont.systemFont(ofSize: 28, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        let titleStr = NSString(string: title)
        titleStr.draw(at: CGPoint(x: 30, y: size.height - 55), withAttributes: attrs)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateStr = NSString(string: formatter.string(from: Date()))
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .medium),
            .foregroundColor: UIColor(white: 0.9, alpha: 0.9)
        ]
        let dateSize = dateStr.size(withAttributes: dateAttrs)
        dateStr.draw(at: CGPoint(x: size.width - dateSize.width - 30, y: size.height - 52), withAttributes: dateAttrs)
    }

    public static func renderSimulatedBackCamera() -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            // Playful room background gradient
            let colors = [
                UIColor(red: 0.96, green: 0.88, blue: 0.72, alpha: 1.0).cgColor,
                UIColor(red: 0.82, green: 0.92, blue: 0.84, alpha: 1.0).cgColor
            ] as CFArray
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0]) {
                cg.drawLinearGradient(grad, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }

            // Floor
            let floorRect = CGRect(x: 0, y: 700, width: size.width, height: 300)
            UIColor(red: 0.76, green: 0.62, blue: 0.48, alpha: 1.0).setFill()
            cg.fill(floorRect)

            // Colorful toy blocks
            let block1 = CGRect(x: 120, y: 620, width: 140, height: 140)
            UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0).setFill()
            cg.fill(block1)
            let block2 = CGRect(x: 280, y: 650, width: 120, height: 110)
            UIColor(red: 0.25, green: 0.65, blue: 0.95, alpha: 1.0).setFill()
            cg.fill(block2)
            let block3 = CGRect(x: 180, y: 510, width: 110, height: 110)
            UIColor(red: 1.0, green: 0.82, blue: 0.2, alpha: 1.0).setFill()
            cg.fill(block3)

            // Teddy bear toy
            let bearHead = CGRect(x: 500, y: 560, width: 160, height: 140)
            UIColor(red: 0.62, green: 0.42, blue: 0.28, alpha: 1.0).setFill()
            cg.fillEllipse(in: bearHead)
            // Bear ears
            cg.fillEllipse(in: CGRect(x: 480, y: 530, width: 50, height: 50))
            cg.fillEllipse(in: CGRect(x: 630, y: 530, width: 50, height: 50))
            // Bear eyes & nose
            UIColor.black.setFill()
            cg.fillEllipse(in: CGRect(x: 540, y: 600, width: 16, height: 16))
            cg.fillEllipse(in: CGRect(x: 600, y: 600, width: 16, height: 16))
            cg.fillEllipse(in: CGRect(x: 565, y: 630, width: 26, height: 18))

            // Label
            let str = NSString(string: "🧸 Rear Camera View")
            str.draw(at: CGPoint(x: 40, y: 60), withAttributes: [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                .foregroundColor: UIColor.darkGray
            ])
        }
    }

    public static func renderSimulatedFrontCamera(sticker: String?) -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            // Cheerful pastel backdrop
            let colors = [
                UIColor(red: 0.72, green: 0.85, blue: 0.98, alpha: 1.0).cgColor,
                UIColor(red: 0.98, green: 0.82, blue: 0.90, alpha: 1.0).cgColor
            ] as CFArray
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0]) {
                cg.drawLinearGradient(grad, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }

            // Toddler selfie head
            let headRect = CGRect(x: 220, y: 320, width: 360, height: 420)
            UIColor(red: 1.0, green: 0.86, blue: 0.78, alpha: 1.0).setFill()
            cg.fillEllipse(in: headRect)

            // Rosy cheeks
            UIColor(red: 1.0, green: 0.6, blue: 0.65, alpha: 0.6).setFill()
            cg.fillEllipse(in: CGRect(x: 250, y: 520, width: 70, height: 40))
            cg.fillEllipse(in: CGRect(x: 480, y: 520, width: 70, height: 40))

            // Cheerful big eyes
            UIColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 1.0).setFill()
            cg.fillEllipse(in: CGRect(x: 310, y: 440, width: 44, height: 56))
            cg.fillEllipse(in: CGRect(x: 446, y: 440, width: 44, height: 56))
            // Eye sparkles
            UIColor.white.setFill()
            cg.fillEllipse(in: CGRect(x: 322, y: 448, width: 16, height: 16))
            cg.fillEllipse(in: CGRect(x: 458, y: 448, width: 16, height: 16))

            // Sweet toddler smile
            UIColor(red: 0.9, green: 0.3, blue: 0.35, alpha: 1.0).setStroke()
            let mouthPath = UIBezierPath()
            mouthPath.addArc(withCenter: CGPoint(x: 400, y: 550), radius: 55, startAngle: 0.15 * .pi, endAngle: 0.85 * .pi, clockwise: false)
            mouthPath.lineWidth = 10
            mouthPath.lineCapStyle = .round
            mouthPath.stroke()

            // Baby curls hair
            UIColor(red: 0.45, green: 0.28, blue: 0.15, alpha: 1.0).setFill()
            cg.fillEllipse(in: CGRect(x: 280, y: 270, width: 90, height: 90))
            cg.fillEllipse(in: CGRect(x: 350, y: 250, width: 100, height: 90))
            cg.fillEllipse(in: CGRect(x: 430, y: 270, width: 90, height: 90))

            // Sticker if active
            if let st = sticker {
                let font = UIFont.systemFont(ofSize: 110)
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                let stStr = NSString(string: st)
                stStr.draw(at: CGPoint(x: 340, y: 190), withAttributes: attrs)
            }

            // Label
            let str = NSString(string: "👶 Toddler Selfie")
            str.draw(at: CGPoint(x: 40, y: 60), withAttributes: [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                .foregroundColor: UIColor.darkGray
            ])
        }
    }
}
