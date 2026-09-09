import Foundation
import UIKit
import Combine

public final class GuidedAccessManager: ObservableObject {
    public static let shared = GuidedAccessManager()

    @Published public var isGuidedAccessActive: Bool = false

    private var cancellables = Set<AnyCancellable>()

    public init() {
        checkStatus()
        NotificationCenter.default.publisher(for: UIAccessibility.guidedAccessStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.checkStatus()
            }
            .store(in: &cancellables)
    }

    public func checkStatus() {
        DispatchQueue.main.async {
            self.isGuidedAccessActive = UIAccessibility.isGuidedAccessEnabled
        }
    }

    public func openGuidedAccessSettings() {
        // First try direct accessibility path, fallback to app settings
        let candidateURLs = [
            "App-Prefs:root=ACCESSIBILITY&path=GUIDED_ACCESS_TITLE",
            "App-Prefs:ACCESSIBILITY",
            UIApplication.openSettingsURLString
        ]

        for urlString in candidateURLs {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }

        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
