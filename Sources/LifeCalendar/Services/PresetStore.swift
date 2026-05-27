import Foundation
import Combine

/// Persists user presets in UserDefaults as a JSON array. Hands out an
/// `@Published` list so views re-render when presets change.
@MainActor
final class PresetStore: ObservableObject {
    static let shared = PresetStore()

    private static let key = "presets.v1"
    private let defaults = UserDefaults.standard

    @Published private(set) var presets: [Preset] = []

    init() {
        load()
    }

    // MARK: - CRUD

    func save(_ preset: Preset) {
        if let idx = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[idx] = preset
        } else {
            presets.insert(preset, at: 0)
        }
        persist()
    }

    func delete(id: UUID) {
        presets.removeAll { $0.id == id }
        persist()
    }

    func snapshot(from settings: Settings, named name: String) -> Preset {
        Preset(
            name: name,
            totalYears: settings.totalYears,
            columns: settings.columns,
            fadeInYears: settings.fadeInYears,
            fadeOutYears: settings.fadeOutYears,
            minScale: settings.minScale,
            minOpacity: settings.minOpacity,
            gridScale: settings.gridScale,
            gridAnchor: settings.gridAnchor,
            sidePadding: settings.sidePadding,
            backgroundHex: settings.backgroundHex,
            foregroundHex: settings.foregroundHex,
            backgroundImagePath: settings.backgroundImagePath,
            dotImagePath: settings.dotImagePath,
            backgroundImageMode: settings.backgroundImageMode,
            dotShape: settings.dotShape,
            iconSize: settings.iconSize,
            currentYearStyle: settings.currentYearStyle,
            currentYearHex: settings.currentYearHex,
            currentYearImagePath: settings.currentYearImagePath,
            gridOpacity: settings.gridOpacity
        )
    }

    func apply(_ preset: Preset, to settings: Settings) {
        settings.totalYears = preset.totalYears
        settings.columns = preset.columns
        settings.fadeInYears = preset.fadeInYears
        settings.fadeOutYears = preset.fadeOutYears
        settings.minScale = preset.minScale
        settings.minOpacity = preset.minOpacity
        settings.gridScale = preset.gridScale
        settings.gridAnchor = preset.gridAnchor
        settings.sidePadding = preset.sidePadding
        settings.backgroundHex = preset.backgroundHex
        settings.foregroundHex = preset.foregroundHex
        settings.backgroundImagePath = preset.backgroundImagePath
        settings.dotImagePath = preset.dotImagePath
        settings.backgroundImageMode = preset.backgroundImageMode
        settings.dotShape = preset.dotShape
        settings.iconSize = preset.iconSize
        settings.currentYearStyle = preset.currentYearStyle
        settings.currentYearHex = preset.currentYearHex
        settings.currentYearImagePath = preset.currentYearImagePath
        settings.gridOpacity = preset.gridOpacity
    }

    // MARK: - Persistence

    private func load() {
        guard let data = defaults.data(forKey: Self.key) else { return }
        if let decoded = try? JSONDecoder().decode([Preset].self, from: data) {
            presets = decoded
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(presets) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
