import SwiftUI

public struct StickersOverlayView: View {
    @ObservedObject var cameraManager = DualCameraManager.shared

    private let stickers = ["👑", "🦁", "🐱", "🕶️", "⭐️", "🎩", "🐶", "🐰"]

    public init() {}

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Clear button
                Button(action: {
                    SoundEffectManager.shared.play(.pop)
                    cameraManager.activeSticker = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(cameraManager.activeSticker == nil ? .yellow : .white.opacity(0.8))
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }

                ForEach(stickers, id: \.self) { sticker in
                    Button(action: {
                        SoundEffectManager.shared.play(.boing)
                        if cameraManager.activeSticker == sticker {
                            cameraManager.activeSticker = nil
                        } else {
                            cameraManager.activeSticker = sticker
                        }
                    }) {
                        Text(sticker)
                            .font(.system(size: 32))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(cameraManager.activeSticker == sticker ? Color.yellow.opacity(0.8) : Color.black.opacity(0.4))
                            )
                            .overlay(
                                Circle()
                                    .stroke(cameraManager.activeSticker == sticker ? Color.white : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.black.opacity(0.35))
        .cornerRadius(24)
        .padding(.horizontal, 12)
    }
}
