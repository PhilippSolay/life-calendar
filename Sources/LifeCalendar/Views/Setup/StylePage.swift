import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Style tab of the setup panel: background source (color OR image), icon
/// source (color OR image), current-year style, and grid opacity.
struct StylePage: View {
    @EnvironmentObject var settings: Settings

    @State private var bgMode: SourceMode = .color
    @State private var dotsMode: SourceMode = .color

    enum SourceMode: String, CaseIterable, Identifiable {
        case color, image
        var id: String { rawValue }
        var label: String { self == .color ? "Color" : "Image" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            wallpaperBackgroundSection
            iconsSection
            currentYearSection
            opacitySection
        }
        .onAppear {
            bgMode = settings.backgroundImage == nil ? .color : .image
            dotsMode = settings.dotImage == nil ? .color : .image
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var wallpaperBackgroundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("WALLPAPER BACKGROUND")

            SourceModeSegmented(
                value: bgMode,
                onChange: { newMode in
                    bgMode = newMode
                    if newMode == .color {
                        // Clearing the image means the user's chosen color
                        // shows in the live preview behind the panel.
                        settings.clearBackgroundImage()
                    }
                }
            )

            Group {
                if bgMode == .color {
                    ColorField(label: "Color", hex: $settings.backgroundHex)
                } else {
                    backgroundImageControls
                }
            }
        }
    }

    @ViewBuilder
    private var backgroundImageControls: some View {
        if let image = settings.backgroundImage {
            FilenameChip(
                name: URL(fileURLWithPath: settings.backgroundImagePath).lastPathComponent,
                thumb: image,
                onRemove: { settings.clearBackgroundImage() }
            )
        } else {
            HStack(spacing: 6) {
                GlassButton(size: .sm, action: { pickImage(into: .background) }) {
                    Text("Select image…")
                }
                GlassButton(size: .sm, action: { settings.importCurrentWallpaper() }) {
                    Text("Use current")
                }
            }
        }
    }

    // MARK: - Icons (dots)

    @ViewBuilder
    private var iconsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("ICONS")

            SourceModeSegmented(
                value: dotsMode,
                onChange: { newMode in
                    dotsMode = newMode
                    if newMode == .color {
                        settings.clearDotImage()
                    }
                }
            )

            Group {
                if dotsMode == .color {
                    ColorField(label: "Color", hex: $settings.foregroundHex)
                } else {
                    iconsImageControls
                }
            }
        }
    }

    @ViewBuilder
    private var iconsImageControls: some View {
        if let image = settings.dotImage {
            FilenameChip(
                name: URL(fileURLWithPath: settings.dotImagePath).lastPathComponent,
                thumb: image,
                onRemove: { settings.clearDotImage() }
            )
        } else {
            GlassButton(size: .sm, action: { pickImage(into: .dots) }) {
                Text("Select image…")
            }
        }
    }

    // MARK: - Current year

    @ViewBuilder
    private var currentYearSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel("CURRENT YEAR")
            CurrentYearSegmented(
                value: settings.currentYearStyle,
                onChange: { settings.currentYearStyle = $0 }
            )
        }
    }

    // MARK: - Opacity

    @ViewBuilder
    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionLabel("OPACITY")
                Spacer()
                Text("\(Int(settings.gridOpacity * 100))%")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.45))
            }
            DesignSlider(
                value: Binding(
                    get: { settings.gridOpacity },
                    set: { settings.gridOpacity = $0 }
                )
            )
        }
    }

    // MARK: - NSOpenPanel

    private enum ImageSlot { case background, dots }

    private func pickImage(into slot: ImageSlot) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType.image]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        switch slot {
        case .background: settings.importBackgroundImage(from: url)
        case .dots: settings.importDotImage(from: url)
        }
    }
}

// MARK: - Color field (full-width row with color well + native picker)

/// A full-width row showing a color label on the left and a swatch on the right
/// that opens the system color picker when clicked. The native `ColorPicker`
/// underlay handles the dialog; we just style the visible chip.
private struct ColorField: View {
    let label: String
    @Binding var hex: String

    private var color: Binding<Color> {
        Binding(
            get: { Color(hex: hex) },
            set: { hex = $0.toHex() }
        )
    }

    var body: some View {
        ZStack {
            // Underlay: invisible-but-hit-testable native picker (opens the dialog).
            ColorPicker("", selection: color, supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .allowsHitTesting(true)

            HStack {
                Text(label)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.white.opacity(0.70))
                Spacer()
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color.wrappedValue)
                    .frame(width: 28, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Source-mode segmented (Color | Image)

private struct SourceModeSegmented: View {
    let value: StylePage.SourceMode
    let onChange: (StylePage.SourceMode) -> Void

    var body: some View {
        HStack(spacing: 0) {
            cell(.color, label: "Color")
            cell(.image, label: "Image")
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func cell(_ mode: StylePage.SourceMode, label: String) -> some View {
        let isOn = value == mode
        Button { onChange(mode) } label: {
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(isOn ? .white : .white.opacity(0.65))
                .frame(maxWidth: .infinity)
                .frame(height: 26)
                .background(
                    Group {
                        if isOn {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isOn)
    }
}

// MARK: - Current-year segmented

private struct CurrentYearSegmented: View {
    let value: CurrentYearStyle
    let onChange: (CurrentYearStyle) -> Void

    var body: some View {
        HStack(spacing: 0) {
            cell(.outline, label: "Outline")
            cell(.color,   label: "Color")
            cell(.image,   label: "Image")
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func cell(_ style: CurrentYearStyle, label: String) -> some View {
        let isOn = value == style
        Button { onChange(style) } label: {
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(isOn ? .white : .white.opacity(0.65))
                .frame(maxWidth: .infinity)
                .frame(height: 26)
                .background(
                    Group {
                        if isOn {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isOn)
    }
}

// MARK: - Slider

private struct DesignSlider: View {
    @Binding var value: Double
    private let trackHeight: CGFloat = 3
    private let thumbDiameter: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            let p = max(0, min(1, value))
            let trackWidth = geo.size.width
            let thumbX = (trackWidth - thumbDiameter) * CGFloat(p) + thumbDiameter / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, thumbX), height: trackHeight)

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: Color.black.opacity(0.5), radius: 1, y: 1)
                    .offset(x: thumbX - thumbDiameter / 2)
            }
            .frame(height: max(trackHeight, thumbDiameter))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let raw = g.location.x / max(1, trackWidth)
                        value = max(0, min(1, Double(raw)))
                    }
            )
        }
        .frame(height: max(trackHeight, thumbDiameter))
    }
}

#Preview {
    StylePage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
