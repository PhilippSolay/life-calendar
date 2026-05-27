import SwiftUI

/// Full-bleed dark backdrop matching the design's "live" wallpaper preview:
/// `#0a0a0a` base + three warm/violet/indigo radial gradients + a dark vertical
/// linear gradient. Optionally overlays the user's current LifeGridView preview.
struct LiveBackdropView: View {
    let showPreviewGrid: Bool
    let previewSize: CGSize

    init(
        showPreviewGrid: Bool = true,
        previewSize: CGSize = CGSize(width: 450, height: 450)
    ) {
        self.showPreviewGrid = showPreviewGrid
        self.previewSize = previewSize
    }

    var body: some View {
        ZStack {
            // Dark base — #0a0a0a
            Color(red: 0x0a / 255.0, green: 0x0a / 255.0, blue: 0x0a / 255.0)
                .ignoresSafeArea()

            // The CSS background list paints the LAST entry at the bottom and the
            // FIRST entry on top. Stack views accordingly: linear (bottom) →
            // indigo radial → violet radial → warm radial (top). All composited
            // with normal alpha blending — NOT plusLighter.
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
                // Painted in CSS-listed order so the first-listed CSS radial
                // (warm) lands on top of the rest.
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

            if showPreviewGrid {
                previewGrid
                    .frame(width: previewSize.width, height: previewSize.height)
                    .opacity(0.92)
            }
        }
    }

    @ViewBuilder
    private var previewGrid: some View {
        // Read Settings off the MainActor; this view is itself only constructed
        // on the main thread.
        let settings = Settings.shared
        LifeGridView(
            progress: settings.progress(),
            backgroundColor: .clear,
            foregroundColor: Color(hex: settings.foregroundHex),
            backgroundImage: settings.backgroundImage,
            gridScale: settings.gridScale,
            backgroundImageMode: settings.backgroundImageMode,
            dotImage: settings.dotImage,
            gridOpacity: 0.92,
            gridAnchor: .center,
            sidePadding: 0,
            dotShape: settings.dotShape,
            iconSize: settings.iconSize,
            currentYearStyle: settings.currentYearStyle
        )
    }

    /// Paints an elliptical radial blob centered at `center` (in the canvas's
    /// unit space) extending out to roughly `size`. Stops fade to fully clear at
    /// `outerStop` so the blobs blend into the underlying linear gradient.
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

#Preview {
    LiveBackdropView(showPreviewGrid: false)
        .frame(width: 800, height: 600)
}
