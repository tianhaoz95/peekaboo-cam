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
                let emojiScale: CGFloat = isPrimary ? 1.0 : 0.88
                let finalSize = rawEmojiSize * emojiScale

                Text(filter.emoji)
                    .font(.system(size: finalSize))
                    .rotationEffect(Angle(radians: trackingManager.headRoll))
                    .shadow(color: Color.black.opacity(0.35), radius: isPrimary ? 8 : 4, x: 0, y: 3)
                    .position(x: anchor.x, y: anchor.y)
                    .opacity(trackingManager.isFaceDetected ? 1.0 : 0.0)
                    .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.82), value: anchor)
                    .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.82), value: trackingManager.headRoll)
                    .animation(.easeInOut(duration: 0.22), value: trackingManager.isFaceDetected)
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(false)
    }
}
