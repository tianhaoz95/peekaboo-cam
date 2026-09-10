import SwiftUI
import PhotosUI

public struct WatchFaceStudioView: View {
    @ObservedObject var watchManager = WatchFaceManager.shared
    @ObservedObject var cameraManager = DualCameraManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedTab: Int = 0
    @State private var showingPhotoPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var isSharingWatchFace = false
    @State private var showSyncConfirmation = false
    @State private var showSaveSuccessBanner = false
    @State private var isSavingPhoto = false

    private let colorChoices: [(String, Color, UIColor)] = [
        ("White", .white, .white),
        ("Gold", Color(red: 1.0, green: 0.84, blue: 0.0), UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)),
        ("Coral", Color(red: 1.0, green: 0.45, blue: 0.45), UIColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1.0)),
        ("Cyan", Color(red: 0.3, green: 0.85, blue: 0.95), UIColor(red: 0.3, green: 0.85, blue: 0.95, alpha: 1.0)),
        ("Lime", Color(red: 0.6, green: 0.95, blue: 0.4), UIColor(red: 0.6, green: 0.95, blue: 0.4, alpha: 1.0)),
        ("Lilac", Color(red: 0.85, green: 0.7, blue: 1.0), UIColor(red: 0.85, green: 0.7, blue: 1.0, alpha: 1.0))
    ]

    public init(initialTab: Int = 0) {
        self._selectedTab = State(initialValue: initialTab)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Section Picker
                Picker("Studio Mode", selection: $selectedTab) {
                    Text("⌚️ Complications").tag(0)
                    Text("🖼️ Photo Watch Face").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                ScrollView {
                    if selectedTab == 0 {
                        complicationsSettingsView
                    } else {
                        photoWatchFaceView
                    }
                }
            }
            .navigationTitle("Apple Watch Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPickerItem, matching: .images)
            .onChange(of: selectedPickerItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            watchManager.selectedPhoto = uiImage
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tab 1: Complications Settings
    private var complicationsSettingsView: some View {
        VStack(spacing: 20) {
            // Quick launcher hero card
            VStack(spacing: 12) {
                Image(systemName: "applewatch.side.right")
                    .font(.system(size: 42))
                    .foregroundColor(.blue)

                Text("Watch Face Remote Shortcut")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Text("Add the ToddlerCam complication to your favorite Apple Watch face to take photos or make animal sounds with a single tap on your wrist!")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 20)

            // Complication Action Selector
            VStack(alignment: .leading, spacing: 14) {
                Text("Select Default Complication Action")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)

                ForEach(WatchComplicationStyle.allCases) { style in
                    Button(action: {
                        SoundEffectManager.shared.play(.pop)
                        watchManager.selectedComplication = style
                        watchManager.syncComplicationSettingsToWatch()
                        showSyncConfirmation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSyncConfirmation = false
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: style.iconName)
                                .font(.system(size: 24))
                                .foregroundColor(watchManager.selectedComplication == style ? .white : .blue)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle().fill(watchManager.selectedComplication == style ? Color.blue : Color.blue.opacity(0.12))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(style.rawValue)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text(complicationDescription(style))
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if watchManager.selectedComplication == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(watchManager.selectedComplication == style ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }

            if showSyncConfirmation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Synced to Apple Watch!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .transition(.opacity)
            }

            // Open Apple Watch App Button
            Button(action: {
                SoundEffectManager.shared.play(.pop)
                watchManager.openAppleWatchApp()
            }) {
                HStack {
                    Image(systemName: "applewatch")
                        .font(.system(size: 20, weight: .bold))
                    Text("Open Watch App on iPhone")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(18)
                .padding(.horizontal, 20)
            }

            // How to add complication tutorial
            howToAddComplicationCard
                .padding(.horizontal, 20)

            Spacer(minLength: 30)
        }
        .padding(.vertical, 16)
    }

    private func complicationDescription(_ style: WatchComplicationStyle) -> String {
        switch style {
        case .quickShutter: return "One-tap trigger to capture photo immediately"
        case .animalSound: return "Instantly play puppy/duck sound to grab kid's gaze"
        case .cameraRemote: return "Launch full ToddlerCam Remote on your watch"
        case .liveStatus: return "Show ToddlerCam connection & battery status"
        }
    }

    // MARK: - Tab 2: Photo Watch Face Studio
    private var photoWatchFaceView: some View {
        VStack(spacing: 24) {
            // Live Interactive Watch Face Mockup
            WatchFaceMockupView(
                photo: watchManager.selectedPhoto,
                timePosition: watchManager.selectedTimePosition,
                timeColor: Color(watchManager.selectedTimeColor),
                complicationStyle: watchManager.selectedComplication
            )
            .padding(.top, 10)

            // Choose Photo Source
            HStack(spacing: 14) {
                if let latest = cameraManager.latestPhoto {
                    Button(action: {
                        SoundEffectManager.shared.play(.pop)
                        watchManager.selectedPhoto = latest.compositeImage
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Use Latest Dual Photo")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.18))
                        .foregroundColor(.orange)
                        .cornerRadius(14)
                    }
                }

                Button(action: {
                    showingPhotoPicker = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Pick from Photos")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.18))
                    .foregroundColor(.blue)
                    .cornerRadius(14)
                }
            }

            // Time Position Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Time Position")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)

                Picker("Time Position", selection: $watchManager.selectedTimePosition) {
                    ForEach(WatchTimePosition.allCases) { pos in
                        Text(pos.rawValue).tag(pos)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
            }

            // Time Color Palette
            VStack(alignment: .leading, spacing: 8) {
                Text("Time Color")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colorChoices, id: \.0) { item in
                            Button(action: {
                                SoundEffectManager.shared.play(.pop)
                                watchManager.selectedTimeColor = item.2
                            }) {
                                Circle()
                                    .fill(item.1)
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Circle()
                                            .stroke(watchManager.selectedTimeColor == item.2 ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Success Confirmation Toast Banner
            if showSaveSuccessBanner {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Photo Saved to Camera Roll!")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Optimized 820×1004 px. Ready for your Apple Watch.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(Color.green.opacity(0.15))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 1.5))
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .scale))
            }

            // Action 1: Save Photo to Camera Roll (Recommended)
            Button(action: {
                SoundEffectManager.shared.play(.pop)
                isSavingPhoto = true
                watchManager.saveWatchFaceToPhotoLibrary { success in
                    isSavingPhoto = false
                    if success {
                        SoundEffectManager.shared.play(.shutter)
                        withAnimation {
                            showSaveSuccessBanner = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation {
                                showSaveSuccessBanner = false
                            }
                        }
                    }
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text(isSavingPhoto ? "Saving Photo..." : "Save Photo for Watch Face")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
            }
            .disabled(isSavingPhoto)

            // Action 2 & 3: Open Watch App & Share Sheet
            HStack(spacing: 12) {
                // Open Apple Watch App
                Button(action: {
                    SoundEffectManager.shared.play(.pop)
                    watchManager.openAppleWatchApp()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "applewatch")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Open Watch App")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }

                // Share / Export Photo
                Button(action: {
                    SoundEffectManager.shared.play(.pop)
                    watchManager.shareWatchFace { }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share Photo...")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)

            // Apple iOS Watch Face Education & Guide Card
            appleWatchFaceGuideCard
                .padding(.horizontal, 20)

            Spacer(minLength: 30)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Apple Watch Face Creation Guide Card
    private var appleWatchFaceGuideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))

                Text("Why can't apps set Watch Faces directly?")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Text("Apple strictly restricts third-party apps from programmatically altering your Apple Watch face for security, privacy, and battery reasons. Only Apple's Photos app and Watch app can set faces.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .lineSpacing(2)

            Divider()

            Text("2 Easy Ways to Set Your Toddler Photo:")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text("1.")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("**From Apple Photos app (Fastest):** Tap 'Save Photo for Watch Face' above. Open the **Photos** app, tap **Share** ➔ **Create Watch Face** ➔ choose **Photos Face**.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("2.")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text("**Directly on Apple Watch:** Press and hold your watch display, swipe right to **+ (New)**, select **Photos**, and choose this toddler photo.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(18)
    }

    // MARK: - How to Add Complication Card
    private var howToAddComplicationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("How to Add to Your Watch Face")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("1. Firmly press and hold your Apple Watch face display.")
                Text("2. Tap 'Edit' and swipe over to the Complications screen.")
                Text("3. Tap any complication slot and scroll to find 'ToddlerCam'.")
                Text("4. Press the Digital Crown to save and enjoy quick remote control!")
            }
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(18)
    }
}
