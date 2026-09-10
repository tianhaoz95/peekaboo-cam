import SwiftUI

public struct FaceTrackingEmojiOverlayView: View {
    @ObservedObject var trackingManager = FaceTrackingManager.shared
    let isPrimary: Bool

    public init(isPrimary: Bool = true) {
        self.isPrimary = isPrimary
    }

    public var body: some View {
        GeometryReader { geo in
            if let filter = trackingManager.activeFilter {
                let size = geo.size
                let anchor = trackingManager.anchorPoint(for: filter.anchorPosition, in: size)
                let rawEmojiSize = trackingManager.emojiSize(in: size, for: filter)
                let emojiScale: CGFloat = isPrimary ? 1.0 : 0.48
                let finalSize = rawEmojiSize * emojiScale

                Text(filter.emoji)
                    .font(.system(size: finalSize))
                    .shadow(color: Color.black.opacity(0.35), radius: isPrimary ? 8 : 4, x: 0, y: 3)
                    .position(x: anchor.x, y: anchor.y)
                    .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.78), value: anchor)
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(false)
    }
}
