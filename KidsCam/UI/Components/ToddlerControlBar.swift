import SwiftUI

public struct ToddlerControlBar: View {
    @ObservedObject var cameraManager = DualCameraManager.shared
    let onOpenGallery: () -> Void
    let onOpenParentZone: () -> Void

    @State private var isPressingShutter: Bool = false
    private let soundOptions: [SoundType] = [.quack, .woof, .meow, .giggle]
    @State private var soundIndex: Int = 0

    public init(onOpenGallery: @escaping () -> Void, onOpenParentZone: @escaping () -> Void) {
        self.onOpenGallery = onOpenGallery
        self.onOpenParentZone = onOpenParentZone
    }

    public var body: some View {
        HStack(alignment: .center) {
            // Left Group: Gallery Thumbnail + Silly Animal Sound
            HStack(spacing: 14) {
                // 1. Gallery Thumbnail
                Button(action: {
                    SoundEffectManager.shared.play(.pop)
                    onOpenGallery()
                }) {
                    ZStack {
                        if let latest = cameraManager.latestPhoto {
                            Image(uiImage: latest.compositeImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 3))
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }

                // 2. Play Silly Sound Button
                Button(action: {
                    let sound = soundOptions[soundIndex % soundOptions.count]
                    soundIndex += 1
                    SoundEffectManager.shared.play(sound)
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Sound")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.purple.opacity(0.85))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Center: GIANT Shutter Button
            Button(action: {
                cameraManager.capturePhoto()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 84, height: 84)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.35, blue: 0.38), Color(red: 1.0, green: 0.6, blue: 0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressingShutter ? 0.92 : 1.0)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressingShutter = true }
                    .onEnded { _ in isPressingShutter = false }
            )

            // Right Group: Parent Zone Button
            HStack {
                Button(action: {
                    SoundEffectManager.shared.play(.pop)
                    onOpenParentZone()
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Parents")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 54, height: 54)
                    .background(Color.orange.opacity(0.85))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black.opacity(0.55))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
