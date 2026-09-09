import XCTest
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
        let front = DualPhotoRenderer.renderSimulatedFrontCamera(sticker: "👑")
        XCTAssertNotNil(back)
        XCTAssertNotNil(front)

        let compositePip = DualPhotoRenderer.composeDualPhoto(
            backImage: back,
            frontImage: front,
            layout: .pip,
            primaryPosition: .back,
            sticker: "👑"
        )
        XCTAssertEqual(compositePip.size.width, 1200)
        XCTAssertEqual(compositePip.size.height, 1600)

        let compositeFrontPrimary = DualPhotoRenderer.composeDualPhoto(
            backImage: back,
            frontImage: front,
            layout: .pip,
            primaryPosition: .front,
            sticker: nil
        )
        XCTAssertEqual(compositeFrontPrimary.size.width, 1200)
        XCTAssertEqual(compositeFrontPrimary.size.height, 1600)
    }

    func testWatchFaceExportDimensions() {
        let manager = WatchFaceManager.shared
        let sample = DualPhotoRenderer.renderSimulatedFrontCamera(sticker: nil)
        let exported = manager.exportWatchFaceImage(from: sample)
        XCTAssertEqual(exported.size.width, 820)
        XCTAssertEqual(exported.size.height, 1004)
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
}
