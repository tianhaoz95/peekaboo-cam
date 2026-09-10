import SwiftUI

public struct WatchRemoteControlView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared
    @State private var isPressingShutter = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Status bar
                    statusBar

                    // Giant Shutter Button
                    shutterSection

                    // Quick Action Grid
                    quickActionGrid

                    // Photo Review Link
                    NavigationLink(destination: WatchPhotoReviewView()) {
                        HStack {
                            Image(systemName: "photo.stack")
                                .foregroundColor(.orange)
                            Text("Review Last Photo")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                            Spacer()
                            if sessionManager.lastPhotoThumbnail != nil {
                                Circle().fill(Color.green).frame(width: 6, height: 6)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Face Masks (Apple Vision Face Tracking)
                    NavigationLink(destination: WatchFaceEmojiSettingsView()) {
                        HStack {
                            Text(sessionManager.activeFaceEmoji == "none" ? "🎭" : (FaceEmojiType(rawValue: sessionManager.activeFaceEmoji)?.emoji ?? "🎭"))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Face Masks (Vision)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                Text(sessionManager.activeFaceEmoji == "none" ? "None (Tap to set)" : (FaceEmojiType(rawValue: sessionManager.activeFaceEmoji)?.displayName ?? "Active"))
                                    .font(.system(size: 10, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    // Full Soundboard Link
                    NavigationLink(destination: SillySoundboardView()) {
                        HStack {
                            Text("🦆")
                            Text("Silly Soundboard")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
            .navigationTitle("Remote")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Status Bar
    private var statusBar: some View {
        HStack {
            Circle()
                .fill(sessionManager.isReachable ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            Text(sessionManager.isReachable ? "Connected" : "Waiting for Phone")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(sessionManager.isReachable ? .green : .orange)

            Spacer()

            if sessionManager.isToddlerLocked {
                HStack(spacing: 3) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text("Locked")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Shutter Section
    private var shutterSection: some View {
        Button(action: {
            sessionManager.sendShutterCommand()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 78, height: 78)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.35, blue: 0.38), Color(red: 1.0, green: 0.6, blue: 0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)

                Image(systemName: "camera.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressingShutter ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressingShutter = true }
                .onEnded { _ in isPressingShutter = false }
        )
    }

    // MARK: - Quick Action Grid
    private var quickActionGrid: some View {
        HStack(spacing: 8) {
            // Quick Duck Quack Sound
            Button(action: {
                sessionManager.playAnimalSound("quack")
            }) {
                VStack(spacing: 3) {
                    Text("🦆")
                        .font(.system(size: 20))
                    Text("Quack")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.25))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            // Quick Puppy Bark Sound
            Button(action: {
                sessionManager.playAnimalSound("woof")
            }) {
                VStack(spacing: 3) {
                    Text("🐶")
                        .font(.system(size: 20))
                    Text("Woof")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.25))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            // Remote Screen Lock Toggle
            Button(action: {
                sessionManager.toggleLock()
            }) {
                VStack(spacing: 3) {
                    Image(systemName: sessionManager.isToddlerLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(sessionManager.isToddlerLocked ? .yellow : .white)
                    Text(sessionManager.isToddlerLocked ? "Locked" : "Lock")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(sessionManager.isToddlerLocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
