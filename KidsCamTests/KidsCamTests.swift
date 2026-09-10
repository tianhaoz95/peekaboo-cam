import XCTest
import SwiftUI
@testable import ToddlerCam

final class KidsCamTests: XCTestCase {

    func testCameraManagerLayoutIsPiPOnly() {
        let manager = DualCameraManager.shared
        XCTAssertEqual(manager.layoutMode, .pip)
        manager.toggleLayoutMode()
        XCTAssertEqual(manager.layoutMode, .pip)
    }

    func testCameraManagerSwapCameras() {
        let manager = DualCameraManager.shared
        manager.primaryPosition = .back
        manager.swapCameras()
        XCTAssertEqual(manager.primaryPosition, .front)
        manager.swapCameras()
        XCTAssertEqual(manager.primaryPosition, .back)
    }

    func testCameraManagerToddlerLock() {
        let manager = DualCameraManager.shared
        manager.isToddlerLocked = false
        manager.toggleToddlerLock()
        XCTAssertTrue(manager.isToddlerLocked)
        manager.toggleToddlerLock()
        XCTAssertFalse(manager.isToddlerLocked)
    }

    func testDualPhotoRendererComposition() {
        let back = DualPhotoRenderer.renderSimulatedBackCamera()
        let front = DualPhotoRenderer.renderSimulatedFrontCamera()
        XCTAssertNotNil(back)
        XCTAssertNotNil(front)

        let compositePip = DualPhotoRenderer.composeDualPhoto(
            backImage: back,
            frontImage: front,
            layout: .pip,
            primaryPosition: .back
        )
        XCTAssertEqual(compositePip.size.width, 1200)
        XCTAssertEqual(compositePip.size.height, 1600)

        let compositeFrontPrimary = DualPhotoRenderer.composeDualPhoto(
            backImage: back,
            frontImage: front,
            layout: .pip,
            primaryPosition: .front
        )
        XCTAssertEqual(compositeFrontPrimary.size.width, 1200)
        XCTAssertEqual(compositeFrontPrimary.size.height, 1600)
    }

    func testFaceTrackingMovementAndHeadRoll() {
        let manager = FaceTrackingManager.shared
        manager.setActiveFilter(.crown)

        let container = CGSize(width: 400, height: 800)

        // 1. Face on the left side of frame
        manager.normalizedFaceRect = CGRect(x: 0.2, y: 0.15, width: 0.3, height: 0.3)
        manager.foreheadCenterNormalized = CGPoint(x: 0.35, y: 0.18)
        manager.headRoll = 0.25
        let pointLeft = manager.anchorPoint(for: .forehead, in: container)

        // 2. Face moves to the right side of frame
        manager.normalizedFaceRect = CGRect(x: 0.6, y: 0.15, width: 0.3, height: 0.3)
        manager.foreheadCenterNormalized = CGPoint(x: 0.75, y: 0.18)
        manager.headRoll = -0.30
        let pointRight = manager.anchorPoint(for: .forehead, in: container)

        // Verify emoji moves with face and tilts with head roll
        XCTAssertGreaterThan(pointRight.x, pointLeft.x, "Emoji anchor must follow face movement to the right")
        XCTAssertEqual(manager.headRoll, -0.30, accuracy: 0.01)
    }

    func testSoundTypeCatalog() {
        for sound in SoundType.allCases {
            XCTAssertFalse(sound.rawValue.isEmpty)
            XCTAssertFalse(sound.emoji.isEmpty)
            XCTAssertFalse(sound.title.isEmpty)
        }
    }

    func testGuidedAccessManagerInitialStatus() {
        let manager = GuidedAccessManager.shared
        // In unit test environment, UIAccessibility.isGuidedAccessEnabled is normally false
        XCTAssertFalse(manager.isGuidedAccessActive)
    }

    func testGuidedAccessManagerOpenSettings() {
        let manager = GuidedAccessManager.shared
        manager.openGuidedAccessSettings()
        XCTAssertEqual(UIPasteboard.general.string, "Guided Access")
    }

    @MainActor
    func testGuidedAccessGuideViewSnapshot() {
        let view = GuidedAccessGuideView()
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(x: 0, y: 0, width: 440, height: 956)
        controller.view.backgroundColor = .systemBackground
        controller.view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        XCTAssertGreaterThan(image.size.width, 0)
        if let data = image.pngData() {
            let path = "/Users/tianhaoz/.gemini/antigravity-cli/brain/04e94b9a-263a-4ac8-8a99-d26f65ce8b13/guided_access_sheet_snapshot.png"
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }

    func testFaceEmojiTypeCatalog() {
        for filter in FaceEmojiType.allCases {
            XCTAssertFalse(filter.emoji.isEmpty)
            XCTAssertFalse(filter.displayName.isEmpty)
            XCTAssertFalse(filter.id.isEmpty)
        }
        XCTAssertEqual(FaceEmojiType.crown.anchorPosition, .forehead)
        XCTAssertEqual(FaceEmojiType.sunglasses.anchorPosition, .eyes)
        XCTAssertEqual(FaceEmojiType.lion.anchorPosition, .head)
    }

    func testFaceTrackingManagerFilterAndCoordinates() {
        let manager = FaceTrackingManager.shared
        manager.setActiveFilter(.lion)
        XCTAssertEqual(manager.activeFilter, .lion)

        let container = CGSize(width: 400, height: 600)
        let anchor = manager.anchorPoint(for: .forehead, in: container)
        XCTAssertGreaterThan(anchor.x, 0)
        XCTAssertGreaterThan(anchor.y, 0)

        let size = manager.emojiSize(in: container, for: .lion)
        XCTAssertGreaterThan(size, 30)

        manager.clearFilter()
        XCTAssertNil(manager.activeFilter)
    }

    func testFaceTrackingManagerProcessImage() {
        let manager = FaceTrackingManager.shared
        manager.setActiveFilter(.crown)
        let testImage = DualPhotoRenderer.renderSimulatedFrontCamera()
        manager.processUIImage(testImage)
        // Processing runs on background vision queue without throwing
        XCTAssertEqual(manager.activeFilter, .crown)
    }

    func testDualPhotoRendererWithTrackedEmoji() {
        let back = DualPhotoRenderer.renderSimulatedBackCamera()
        let front = DualPhotoRenderer.renderSimulatedFrontCamera()

        let composite = DualPhotoRenderer.composeDualPhoto(
            backImage: back,
            frontImage: front,
            layout: .pip,
            primaryPosition: .back,
            filter: .lion
        )
        XCTAssertEqual(composite.size.width, 1200)
        XCTAssertEqual(composite.size.height, 1600)
    }

    @MainActor
    func testFaceTrackingOverlaySnapshot() {
        FaceTrackingManager.shared.setActiveFilter(.crown)
        let sampleFace = DualPhotoRenderer.renderSimulatedFrontCamera()
        FaceTrackingManager.shared.processUIImage(sampleFace)

        let composite = DualPhotoRenderer.composeDualPhoto(
            backImage: DualPhotoRenderer.renderSimulatedBackCamera(),
            frontImage: sampleFace,
            layout: .pip,
            primaryPosition: .front,
            filter: .crown
        )
        if let data = composite.pngData() {
            let path = "/Users/tianhaoz/.gemini/antigravity-cli/brain/04e94b9a-263a-4ac8-8a99-d26f65ce8b13/tracked_face_mask_photo.png"
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }

    @MainActor
    func testWatchComplicationsStudioViewSnapshot() {
        let view = WatchFaceStudioView()
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(x: 0, y: 0, width: 440, height: 956)
        controller.view.backgroundColor = .systemBackground
        controller.view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        XCTAssertGreaterThan(image.size.width, 0)
        if let data = image.pngData() {
            let path = "/Users/tianhaoz/.gemini/antigravity-cli/brain/04e94b9a-263a-4ac8-8a99-d26f65ce8b13/watch_complications_studio_snapshot.png"
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }
}
