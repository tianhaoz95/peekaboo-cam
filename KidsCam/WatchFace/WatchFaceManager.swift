import Foundation
import UIKit
import WatchConnectivity
import Photos

public enum WatchTimePosition: String, CaseIterable, Identifiable {
    case top = "Top"
    case bottom = "Bottom"
    public var id: String { rawValue }
}

public enum WatchComplicationStyle: String, CaseIterable, Identifiable {
    case quickShutter = "Quick Shutter"
    case animalSound = "Silly Sound"
    case cameraRemote = "Camera Remote"
    case liveStatus = "Status"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .quickShutter: return "camera.circle.fill"
        case .animalSound: return "speaker.wave.3.fill"
        case .cameraRemote: return "applewatch.radiowaves.left.and.right"
        case .liveStatus: return "checkmark.circle.fill"
        }
    }
}

public final class WatchFaceManager: ObservableObject {
    public static let shared = WatchFaceManager()

    @Published public var selectedTimePosition: WatchTimePosition = .top
    @Published public var selectedTimeColor: UIColor = .white
    @Published public var selectedComplication: WatchComplicationStyle = .quickShutter
    @Published public var selectedPhoto: UIImage?

    public init() {
        // Default preview photo: render simulated toddler selfie if no photo taken yet
        self.selectedPhoto = DualPhotoRenderer.renderSimulatedFrontCamera()
    }

    public func openAppleWatchApp() {
        let watchURLs = [
            "watch://",
            "itms-watch://",
            "App-Prefs:root=WATCH"
        ]
        for urlStr in watchURLs {
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
    }

    public func syncComplicationSettingsToWatch() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.activationState == .activated {
            let info: [String: Any] = [
                "complicationStyle": selectedComplication.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
            if session.isComplicationEnabled {
                session.transferCurrentComplicationUserInfo(info)
            }
            try? session.updateApplicationContext(info)
        }
    }

    public func exportWatchFaceImage(from image: UIImage) -> UIImage {
        // Standard Apple Watch Ultra / Series 9 / 10 resolution: 410 x 502 pt (820 x 1004 px)
        let watchSize = CGSize(width: 820, height: 1004)
        let renderer = UIGraphicsImageRenderer(size: watchSize)

        return renderer.image { ctx in
            // Aspect fill photo
            let imgAspect = image.size.width / image.size.height
            let watchAspect = watchSize.width / watchSize.height

            var drawRect = CGRect.zero
            if imgAspect > watchAspect {
                let h = watchSize.height
                let w = h * imgAspect
                drawRect = CGRect(x: (watchSize.width - w) / 2.0, y: 0, width: w, height: h)
            } else {
                let w = watchSize.width
                let h = w / imgAspect
                drawRect = CGRect(x: 0, y: (watchSize.height - h) / 2.0, width: w, height: h)
            }
            image.draw(in: drawRect)
        }
    }

    public func shareWatchFace(from sourceView: UIView, completion: @escaping () -> Void) {
        guard let photo = selectedPhoto else { return }
        let watchImage = exportWatchFaceImage(from: photo)

        let activityVC = UIActivityViewController(activityItems: [watchImage], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: completion)
        }
    }
}
