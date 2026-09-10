import SwiftUI

public struct ToddlerCameraView: View {
    @ObservedObject var cameraManager = DualCameraManager.shared
    @ObservedObject var guidedManager = GuidedAccessManager.shared
    @ObservedObject var watchConn = WatchConnectivityManager.shared

    @State private var showParentGate = false
    @State private var pendingParentDestination: ParentDestination? = nil
    @State private var isParentGateUnlocked = false
    @State private var showGuidedAccessDirectly = false
    @State private var showParentHub = false
    @State private var showGallery = false

    enum ParentDestination {
        case hub
        case guidedAccess
        case gallery
    }

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Dual Camera Feeds (PiP) - Edge-to-Edge Fullscreen
                DualCameraPreviewView()
                    .ignoresSafeArea()

                // 2. Main Toddler Controls
                VStack(spacing: 0) {
                    // Top Header Bar cleanly positioned below notch / Dynamic Island
                    topHeaderBar
                        .padding(.top, max(geo.safeAreaInsets.top, 48) + 4)

                    Spacer()

                    // Bottom Toddler Control Bar
                    ToddlerControlBar(
                        onOpenGallery: {
                            promptParentGate(for: .gallery)
                        },
                        onOpenParentZone: {
                            promptParentGate(for: .hub)
                        }
                    )
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 12))
                }

                // 3. Toddler Lock Screen (Protects screen from unintentional taps)
                if cameraManager.isToddlerLocked {
                    ToddlerLockOverlay()
                }

                // 4. Parental Gate Challenge
                if showParentGate {
                    ParentGateView(
                        isUnlocked: $isParentGateUnlocked,
                        onUnlocked: {
                            showParentGate = false
                            handleParentUnlock()
                        },
                        onCancel: {
                            showParentGate = false
                            pendingParentDestination = nil
                        }
                    )
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showParentHub) {
            ParentHubView()
        }
        .sheet(isPresented: $showGuidedAccessDirectly) {
            GuidedAccessGuideView()
        }
        .sheet(isPresented: $showGallery) {
            PhotoGalleryView()
        }
        .statusBar(hidden: true)
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }

    // MARK: - Top Header Bar
    private var topHeaderBar: some View {
        HStack(spacing: 10) {
            // Guided Access Quick Status Badge / Setup Shortcut Button
            Button(action: {
                SoundEffectManager.shared.play(.pop)
                promptParentGate(for: .guidedAccess)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: guidedManager.isGuidedAccessActive ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(guidedManager.isGuidedAccessActive ? .green : .orange)

                    Text(guidedManager.isGuidedAccessActive ? "Guided Access ON" : "Guided Access")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.black.opacity(0.55))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(guidedManager.isGuidedAccessActive ? Color.green.opacity(0.6) : Color.orange.opacity(0.6), lineWidth: 1.5)
                )
            }

            Spacer()

            // Watch Connection Indicator
            if watchConn.isReachable {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Image(systemName: "applewatch")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.55))
                .cornerRadius(14)
            }

            // Lock Screen Button
            Button(action: {
                cameraManager.toggleToddlerLock()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: cameraManager.isToddlerLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(cameraManager.isToddlerLocked ? .yellow : .white)
                    Text(cameraManager.isToddlerLocked ? "Locked" : "Lock")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.55))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Parent Gate Handling
    private func promptParentGate(for destination: ParentDestination) {
        pendingParentDestination = destination
        showParentGate = true
    }

    private func handleParentUnlock() {
        guard let dest = pendingParentDestination else { return }
        pendingParentDestination = nil
        switch dest {
        case .hub:
            showParentHub = true
        case .guidedAccess:
            showGuidedAccessDirectly = true
        case .gallery:
            showGallery = true
        }
    }
}
