import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Style tab of the setup panel: wallpaper background source, icon source,
/// current-year style picker, and a grid opacity slider.
struct StylePage: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            wallpaperBackgroundSection
            iconsSection
            currentYearSection
            opacitySection
        }
    }

    // MARK: - Wallpaper background

    @ViewBuilder
    private var wallpaperBackgroundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("WALLPAPER BACKGROUND")

            if let _ = settings.backgroundImage {
                FilenameChip(
                    name: URL(fileURLWithPath: settings.backgroundImagePath).lastPathComponent,
                    onRemove: { settings.clearBackgroundImage() }
                )
            } else {
                ColorChip(label: "Color", hex: $settings.backgroundHex)
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
    }

    // MARK: - Icons

    @ViewBuilder
    private var iconsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("ICONS")

            HStack(spacing: 8) {
                ColorChip(label: "Color", hex: $settings.foregroundHex)
                GlassButton(size: .sm, action: { pickImage(into: .dots) }) {
                    Text("Select image…")
                }
            }

            if settings.dotImage != nil {
                FilenameChip(
                    name: URL(fileURLWithPath: settings.dotImagePath).lastPathComponent,
                    onRemove: { settings.clearDotImage() }
                )
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

/// Custom slider matching `.slider` from styles.css: 3pt track (white fill →
/// white-15% remainder), 14pt circular thumb with soft drop shadow.
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
                // Track background (remaining)
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: trackHeight)

                // Track fill
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, thumbX), height: trackHeight)

                // Thumb
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

/// Small segmented control bound to `CurrentYearStyle`. Three options:
/// outline / color / image. Visual styling matches `.segmented` in styles.css.
private struct CurrentYearSegmented: View {
    let value: CurrentYearStyle
    let onChange: (CurrentYearStyle) -> Void

    private let buttonHeight: CGFloat = 26
    private let buttonRadius: CGFloat = 6
    private let outerPadding: CGFloat = 3
    private let outerRadius: CGFloat = 8

    var body: some View {
        HStack(spacing: 0) {
            cell(.outline, label: "Outline")
            cell(.color,   label: "Color")
            cell(.image,   label: "Image")
        }
        .padding(outerPadding)
        .background(
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func cell(_ style: CurrentYearStyle, label: String) -> some View {
        let isOn = value == style
        Button {
            onChange(style)
        } label: {
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(isOn ? .white : .white.opacity(0.65))
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(
                    Group {
                        if isOn {
                            RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: buttonRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isOn)
    }
}

#Preview {
    StylePage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
