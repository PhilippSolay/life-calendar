import SwiftUI

/// Full-bleed backdrop that renders either:
/// - `.photo` — the marketing photo gradient used behind the Birthday flow.
/// - `.userWallpaper` — the user's actual wallpaper (color or image + the dot
///   grid on top) rendered at full screen. This is what the Setup window shows
///   behind the floating inspector; tweaks to settings reflect immediately.
struct LiveBackdropView: View {
    enum Style {
        case photo
        case userWallpaper
    }

    let style: Style

    @EnvironmentObject private var settings: Settings

    init(style: Style = .photo) {
        self.style = style
    }

    var body: some View {
        switch style {
        case .photo:        photoBackdrop
        case .userWallpaper: userWallpaperBackdrop
        }
    }

    // MARK: - Photo backdrop (Birthday flow)

    private var photoBackdrop: some View {
        ZStack {
            Color(red: 0x0a / 255.0, green: 0x0a / 255.0, blue: 0x0a / 255.0)
                .ignoresSafeArea()

            LinearGradient(
                stops: [
                    .init(color: Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x28 / 255.0), location: 0.0),
                    .init(color: Color(red: 0x2a / 255.0, green: 0x1c / 255.0, blue: 0x20 / 255.0), location: 0.45),
                    .init(color: Color(red: 0x06 / 255.0, green: 0x04 / 255.0, blue: 0x10 / 255.0), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    radialBlob(
                        center: UnitPoint(x: 0.90, y: 0.90),
                        size: CGSize(width: geo.size.width * 0.50, height: geo.size.height * 0.70),
                        color: Color(red: 60.0 / 255.0, green: 40.0 / 255.0, blue: 90.0 / 255.0).opacity(0.60),
                        outerStop: 0.60,
                        canvas: geo.size
                    )
                    radialBlob(
                        center: UnitPoint(x: 0.75, y: 0.25),
                        size: CGSize(width: geo.size.width * 0.60, height: geo.size.height * 0.50),
                        color: Color(red: 120.0 / 255.0, green: 90.0 / 255.0, blue: 160.0 / 255.0).opacity(0.60),
                        outerStop: 0.70,
                        canvas: geo.size
                    )
                    radialBlob(
                        center: UnitPoint(x: 0.30, y: 0.80),
                        size: CGSize(width: geo.size.width * 0.80, height: geo.size.height * 0.60),
                        color: Color(red: 220.0 / 255.0, green: 170.0 / 255.0, blue: 90.0 / 255.0).opacity(0.65),
                        outerStop: 0.60,
                        canvas: geo.size
                    )
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - User wallpaper backdrop (Setup window)

    private var userWallpaperBackdrop: some View {
        // Renders exactly what the wallpaper PNG will look like, at the full
        // window size. The user's chosen background color or image fills behind
        // the grid; tweaks update in real time because we observe Settings.
        LifeGridView(
            progress: settings.progress(),
            backgroundColor: Color(hex: settings.backgroundHex),
            foregroundColor: Color(hex: settings.foregroundHex),
            backgroundImage: settings.backgroundImage,
            gridScale: settings.gridScale,
            backgroundImageMode: settings.backgroundImageMode,
            dotImage: settings.dotImage,
            gridOpacity: settings.gridOpacity,
            gridAnchor: settings.gridAnchor,
            sidePadding: settings.sidePadding,
            dotShape: settings.dotShape,
            iconSize: settings.iconSize,
            currentYearStyle: settings.currentYearStyle,
            currentYearHex: settings.currentYearHex,
            currentYearImage: settings.currentYearImage
        )
        .ignoresSafeArea()
    }

    private func radialBlob(
        center: UnitPoint,
        size: CGSize,
        color: Color,
        outerStop: CGFloat,
        canvas: CGSize
    ) -> some View {
        RadialGradient(
            stops: [
                .init(color: color, location: 0.0),
                .init(color: color.opacity(0), location: outerStop)
            ],
            center: center,
            startRadius: 0,
            endRadius: max(size.width, size.height)
        )
        .frame(width: canvas.width, height: canvas.height)
    }
}

#Preview("Photo") {
    LiveBackdropView(style: .photo)
        .frame(width: 800, height: 600)
}

#Preview("User wallpaper") {
    LiveBackdropView(style: .userWallpaper)
        .frame(width: 800, height: 600)
}
