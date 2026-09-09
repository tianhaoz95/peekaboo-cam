import SwiftUI

public struct WatchFaceMockupView: View {
    let photo: UIImage?
    let timePosition: WatchTimePosition
    let timeColor: Color
    let complicationStyle: WatchComplicationStyle

    public init(photo: UIImage?, timePosition: WatchTimePosition, timeColor: Color, complicationStyle: WatchComplicationStyle) {
        self.photo = photo
        self.timePosition = timePosition
        self.timeColor = timeColor
        self.complicationStyle = complicationStyle
    }

    public var body: some View {
        ZStack {
            // Digital Crown
            HStack {
                Spacer()
                VStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [Color.gray, Color.black, Color.gray], startPoint: .top, endPoint: .bottom))
                        .frame(width: 14, height: 56)
                        .offset(x: 10, y: -45)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 8, height: 42)
                        .offset(x: 7, y: 15)
                }
            }
            .frame(width: 250, height: 300)

            // Watch Case (Aluminum / Titanium Dark Frame)
            RoundedRectangle(cornerRadius: 44)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.28), Color(white: 0.12), Color(white: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 230, height: 280)
                .shadow(color: Color.black.opacity(0.4), radius: 14, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                )

            // Watch Display Screen (Bezel & Content)
            ZStack {
                Color.black

                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 196, height: 246)
                        .clipped()
                } else {
                    Color(white: 0.1)
                }

                // Subtle top and bottom dark gradient for readability
                LinearGradient(
                    colors: [Color.black.opacity(0.55), Color.clear, Color.black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Watch Face Overlay UI (Time, Date, Complication)
                VStack {
                    if timePosition == .top {
                        timeSection
                        Spacer()
                        bottomComplicationSection
                    } else {
                        topComplicationSection
                        Spacer()
                        timeSection
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
            }
            .frame(width: 196, height: 246)
            .cornerRadius(34)
        }
    }

    // MARK: - Time Section
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: -4) {
            Text("WED 9")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(timeColor.opacity(0.85))

            Text("09:41")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(timeColor)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Complication Sections
    private var topComplicationSection: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: complicationStyle.iconName)
                    .font(.system(size: 11, weight: .bold))
                Text(complicationStyle.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)

            Spacer()
        }
    }

    private var bottomComplicationSection: some View {
        HStack {
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: complicationStyle.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                Text("ToddlerCam")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
        }
    }
}
