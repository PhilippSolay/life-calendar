import SwiftUI
import AppKit

/// Presets tab: a 2-column scrolling grid of saved preset cards. Each card
/// shows a miniature live preview of the wallpaper the preset would produce,
/// plus its name. Tapping a card applies the preset to Settings.
struct PresetsPage: View {
    @EnvironmentObject var settings: Settings
    @StateObject private var store = PresetStore.shared

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("PRESETS")

            if store.presets.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(store.presets) { preset in
                            PresetCard(
                                preset: preset,
                                onApply: { store.apply(preset, to: settings) },
                                onDelete: { store.delete(id: preset.id) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: 320)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("No presets yet.")
                .font(.system(size: 12.5))
                .foregroundStyle(.white.opacity(0.7))
            Text("Save the current look from the Save tab.")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 18)
    }
}

/// One preset thumbnail card. Renders a small LifeGridView with the preset's
/// values; tap to apply, with a delete affordance on hover.
private struct PresetCard: View {
    let preset: Preset
    let onApply: () -> Void
    let onDelete: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: onApply) {
            VStack(spacing: 0) {
                preview
                    .aspectRatio(16.0 / 10.0, contentMode: .fit)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        if hovering {
                            IconButton(text: "×", diameter: 20, action: onDelete)
                                .padding(6)
                        }
                    }

                Text(preset.name)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }

    private var preview: some View {
        // A tiny LifeGridView with the preset's values. Image paths point at
        // App Support files; if they were deleted the load returns nil and the
        // preview falls back to the color-only background.
        LifeGridView(
            progress: LifeProgress(
                birthdate: Calendar.current.date(byAdding: .year, value: -42, to: Date()) ?? Date(),
                totalYears: preset.totalYears,
                columns: preset.columns,
                fadeInYears: preset.fadeInYears,
                fadeOutYears: preset.fadeOutYears,
                minScale: preset.minScale,
                minOpacity: preset.minOpacity,
                now: Date()
            ),
            backgroundColor: Color(hex: preset.backgroundHex),
            foregroundColor: Color(hex: preset.foregroundHex),
            backgroundImage: loadImage(at: preset.backgroundImagePath),
            gridScale: preset.gridScale,
            backgroundImageMode: preset.backgroundImageMode,
            dotImage: loadImage(at: preset.dotImagePath),
            gridOpacity: preset.gridOpacity,
            gridAnchor: preset.gridAnchor,
            sidePadding: preset.sidePadding,
            dotShape: preset.dotShape,
            iconSize: preset.iconSize,
            currentYearStyle: preset.currentYearStyle
        )
    }

    private func loadImage(at path: String) -> NSImage? {
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }
}

#Preview {
    PresetsPage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
