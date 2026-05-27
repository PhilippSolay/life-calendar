import SwiftUI
import AppKit
import Combine

enum GridAnchor: String, CaseIterable, Identifiable {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing

    var id: String { rawValue }

    enum HorizontalAnchor { case leading, center, trailing }
    enum VerticalAnchor { case top, center, bottom }

    var horizontal: HorizontalAnchor {
        switch self {
        case .topLeading, .leading, .bottomLeading: return .leading
        case .top, .center, .bottom: return .center
        case .topTrailing, .trailing, .bottomTrailing: return .trailing
        }
    }

    var vertical: VerticalAnchor {
        switch self {
        case .topLeading, .top, .topTrailing: return .top
        case .leading, .center, .trailing: return .center
        case .bottomLeading, .bottom, .bottomTrailing: return .bottom
        }
    }

    var isCentered: Bool { self == .center }

    /// 0...8 index into the 3×3 anchor grid (row-major: top-leading is 0,
    /// bottom-trailing is 8). Used by the inspector swatches.
    var index: Int {
        switch self {
        case .topLeading: return 0
        case .top: return 1
        case .topTrailing: return 2
        case .leading: return 3
        case .center: return 4
        case .trailing: return 5
        case .bottomLeading: return 6
        case .bottom: return 7
        case .bottomTrailing: return 8
        }
    }

    static func from(index: Int) -> GridAnchor {
        switch index {
        case 0: return .topLeading
        case 1: return .top
        case 2: return .topTrailing
        case 3: return .leading
        case 4: return .center
        case 5: return .trailing
        case 6: return .bottomLeading
        case 7: return .bottom
        case 8: return .bottomTrailing
        default: return .center
        }
    }
}

enum BackgroundImageMode: String, CaseIterable, Identifiable {
    case fullScreen
    case insideRings
    case ringOutlines

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fullScreen: return "Fill wallpaper"
        case .insideRings: return "Inside the rings"
        case .ringOutlines: return "On ring outlines"
        }
    }
}

enum DotShape: String, CaseIterable, Identifiable {
    case circle
    case roundedSquare
    case square

    var id: String { rawValue }
}

enum CurrentYearStyle: String, CaseIterable, Identifiable {
    case outline
    case color
    case image

    var id: String { rawValue }
}

enum SettingsKey {
    static let birthdate = "birthdate"
    static let hasOnboarded = "hasOnboarded"
    static let backgroundHex = "backgroundHex"
    static let foregroundHex = "foregroundHex"
    static let totalYears = "totalYears"
    static let columns = "columns"
    static let fadeInYears = "fadeInYears"
    static let fadeOutYears = "fadeOutYears"
    static let minScale = "minScale"
    static let minOpacity = "minOpacity"
    static let backgroundImagePath = "backgroundImagePath"
    static let gridScale = "gridScale"
    static let backgroundImageMode = "backgroundImageMode"
    static let dotImagePath = "dotImagePath"
    static let gridOpacity = "gridOpacity"
    static let originalWallpaperPath = "originalWallpaperPath"
    static let gridAnchor = "gridAnchor"
    static let sidePadding = "sidePadding"
    static let dotShape = "dotShape"
    static let iconSize = "iconSize"
    static let currentYearStyle = "currentYearStyle"

    // Legacy keys removed from the model but used during migration.
    static let legacyHighlightCurrentYear = "highlightCurrentYear"
}

@MainActor
final class Settings: ObservableObject {
    static let shared = Settings()

    private let defaults = UserDefaults.standard

    @Published var birthdate: Date {
        didSet { defaults.set(birthdate.timeIntervalSince1970, forKey: SettingsKey.birthdate) }
    }

    @Published var hasOnboarded: Bool {
        didSet { defaults.set(hasOnboarded, forKey: SettingsKey.hasOnboarded) }
    }

    @Published var backgroundHex: String {
        didSet { defaults.set(backgroundHex, forKey: SettingsKey.backgroundHex) }
    }

    @Published var foregroundHex: String {
        didSet { defaults.set(foregroundHex, forKey: SettingsKey.foregroundHex) }
    }

    @Published var totalYears: Int {
        didSet { defaults.set(totalYears, forKey: SettingsKey.totalYears) }
    }

    @Published var columns: Int {
        didSet { defaults.set(columns, forKey: SettingsKey.columns) }
    }

    @Published var fadeInYears: Int {
        didSet { defaults.set(fadeInYears, forKey: SettingsKey.fadeInYears) }
    }

    @Published var fadeOutYears: Int {
        didSet { defaults.set(fadeOutYears, forKey: SettingsKey.fadeOutYears) }
    }

    @Published var minScale: Double {
        didSet { defaults.set(minScale, forKey: SettingsKey.minScale) }
    }

    @Published var minOpacity: Double {
        didSet { defaults.set(minOpacity, forKey: SettingsKey.minOpacity) }
    }

    @Published var backgroundImagePath: String {
        didSet { defaults.set(backgroundImagePath, forKey: SettingsKey.backgroundImagePath) }
    }

    @Published var gridScale: Double {
        didSet { defaults.set(gridScale, forKey: SettingsKey.gridScale) }
    }

    @Published var backgroundImageMode: BackgroundImageMode {
        didSet { defaults.set(backgroundImageMode.rawValue, forKey: SettingsKey.backgroundImageMode) }
    }

    @Published var dotImagePath: String {
        didSet { defaults.set(dotImagePath, forKey: SettingsKey.dotImagePath) }
    }

    @Published var gridOpacity: Double {
        didSet { defaults.set(gridOpacity, forKey: SettingsKey.gridOpacity) }
    }

    @Published var originalWallpaperPath: String {
        didSet { defaults.set(originalWallpaperPath, forKey: SettingsKey.originalWallpaperPath) }
    }

    @Published var gridAnchor: GridAnchor {
        didSet { defaults.set(gridAnchor.rawValue, forKey: SettingsKey.gridAnchor) }
    }

    @Published var sidePadding: Double {
        didSet { defaults.set(sidePadding, forKey: SettingsKey.sidePadding) }
    }

    @Published var dotShape: DotShape {
        didSet { defaults.set(dotShape.rawValue, forKey: SettingsKey.dotShape) }
    }

    @Published var iconSize: Double {
        didSet { defaults.set(iconSize, forKey: SettingsKey.iconSize) }
    }

    @Published var currentYearStyle: CurrentYearStyle {
        didSet { defaults.set(currentYearStyle.rawValue, forKey: SettingsKey.currentYearStyle) }
    }

    init() {
        // Migrate legacy `highlightCurrentYear` BEFORE registering defaults so that
        // the legacy key's value (if any) drives the seeded currentYearStyle.
        let migratedCurrentYearStyle = Settings.migrateHighlightCurrentYear(defaults: defaults)

        defaults.register(defaults: [
            SettingsKey.backgroundHex: "#000000",
            SettingsKey.foregroundHex: "#FFFFFF",
            SettingsKey.totalYears: 110,
            SettingsKey.columns: 10,
            SettingsKey.fadeInYears: 20,
            SettingsKey.fadeOutYears: 20,
            SettingsKey.minScale: 0.08,
            SettingsKey.minOpacity: 0.12,
            SettingsKey.backgroundImagePath: "",
            SettingsKey.gridScale: 0.5,
            SettingsKey.backgroundImageMode: BackgroundImageMode.fullScreen.rawValue,
            SettingsKey.dotImagePath: "",
            SettingsKey.gridOpacity: 1.0,
            SettingsKey.originalWallpaperPath: "",
            SettingsKey.gridAnchor: GridAnchor.center.rawValue,
            SettingsKey.sidePadding: 0.05,
            SettingsKey.dotShape: DotShape.circle.rawValue,
            SettingsKey.iconSize: 0.64,
            SettingsKey.currentYearStyle: migratedCurrentYearStyle.rawValue
        ])

        let storedBirth = defaults.double(forKey: SettingsKey.birthdate)
        self.birthdate = storedBirth > 0
            ? Date(timeIntervalSince1970: storedBirth)
            : Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        self.hasOnboarded = defaults.bool(forKey: SettingsKey.hasOnboarded)
        self.backgroundHex = defaults.string(forKey: SettingsKey.backgroundHex) ?? "#000000"
        self.foregroundHex = defaults.string(forKey: SettingsKey.foregroundHex) ?? "#FFFFFF"
        self.totalYears = defaults.integer(forKey: SettingsKey.totalYears)
        self.columns = defaults.integer(forKey: SettingsKey.columns)
        self.fadeInYears = defaults.integer(forKey: SettingsKey.fadeInYears)
        self.fadeOutYears = defaults.integer(forKey: SettingsKey.fadeOutYears)
        self.minScale = defaults.double(forKey: SettingsKey.minScale)
        self.minOpacity = defaults.double(forKey: SettingsKey.minOpacity)
        self.backgroundImagePath = defaults.string(forKey: SettingsKey.backgroundImagePath) ?? ""
        let storedScale = defaults.double(forKey: SettingsKey.gridScale)
        self.gridScale = storedScale > 0 ? storedScale : 1.0
        let modeRaw = defaults.string(forKey: SettingsKey.backgroundImageMode)
            ?? BackgroundImageMode.fullScreen.rawValue
        self.backgroundImageMode = BackgroundImageMode(rawValue: modeRaw) ?? .fullScreen
        self.dotImagePath = defaults.string(forKey: SettingsKey.dotImagePath) ?? ""
        let storedOpacity = defaults.double(forKey: SettingsKey.gridOpacity)
        self.gridOpacity = storedOpacity > 0 ? storedOpacity : 1.0
        self.originalWallpaperPath = defaults.string(forKey: SettingsKey.originalWallpaperPath) ?? ""
        let anchorRaw = defaults.string(forKey: SettingsKey.gridAnchor) ?? GridAnchor.center.rawValue
        self.gridAnchor = GridAnchor(rawValue: anchorRaw) ?? .center
        self.sidePadding = defaults.double(forKey: SettingsKey.sidePadding)
        let dotShapeRaw = defaults.string(forKey: SettingsKey.dotShape) ?? DotShape.circle.rawValue
        self.dotShape = DotShape(rawValue: dotShapeRaw) ?? .circle
        let storedIconSize = defaults.double(forKey: SettingsKey.iconSize)
        self.iconSize = storedIconSize > 0 ? min(max(storedIconSize, 0.0), 1.0) : 0.64
        let currentYearRaw = defaults.string(forKey: SettingsKey.currentYearStyle)
            ?? migratedCurrentYearStyle.rawValue
        self.currentYearStyle = CurrentYearStyle(rawValue: currentYearRaw) ?? migratedCurrentYearStyle
    }

    /// Returns the currentYearStyle dictated by any legacy `highlightCurrentYear` value.
    /// If the legacy key is present, it's mapped (true → .color, false → .outline) and
    /// then deleted. Otherwise the default (.color) is returned.
    private static func migrateHighlightCurrentYear(defaults: UserDefaults) -> CurrentYearStyle {
        guard defaults.object(forKey: SettingsKey.legacyHighlightCurrentYear) != nil else {
            return .color
        }
        let legacy = defaults.bool(forKey: SettingsKey.legacyHighlightCurrentYear)
        defaults.removeObject(forKey: SettingsKey.legacyHighlightCurrentYear)
        return legacy ? .color : .outline
    }

    var backgroundImage: NSImage? { loadImage(at: backgroundImagePath) }
    var dotImage: NSImage? { loadImage(at: dotImagePath) }

    @discardableResult
    func importBackgroundImage(from source: URL) -> Bool {
        guard let path = copyImageToSupport(from: source, prefix: "background") else { return false }
        clearBackgroundImage()
        backgroundImagePath = path
        return true
    }

    @discardableResult
    func importDotImage(from source: URL) -> Bool {
        guard let path = copyImageToSupport(from: source, prefix: "dotimage") else { return false }
        clearDotImage()
        dotImagePath = path
        return true
    }

    func clearBackgroundImage() {
        if !backgroundImagePath.isEmpty {
            try? FileManager.default.removeItem(atPath: backgroundImagePath)
        }
        backgroundImagePath = ""
    }

    func clearDotImage() {
        if !dotImagePath.isEmpty {
            try? FileManager.default.removeItem(atPath: dotImagePath)
        }
        dotImagePath = ""
    }

    /// True if the URL points at a wallpaper file this app generated.
    /// Used to break the feedback loop when re-importing the "current" wallpaper.
    static func isOurOutput(url: URL) -> Bool {
        url.lastPathComponent.hasPrefix("wallpaper-") && url.path.contains("/LifeCalendar/")
    }

    @discardableResult
    func importCurrentWallpaper() -> Bool {
        let sourceURL: URL?
        if let screen = NSScreen.main,
           let current = NSWorkspace.shared.desktopImageURL(for: screen),
           !Self.isOurOutput(url: current) {
            sourceURL = current
        } else if !originalWallpaperPath.isEmpty,
                  FileManager.default.fileExists(atPath: originalWallpaperPath) {
            sourceURL = URL(fileURLWithPath: originalWallpaperPath)
        } else {
            sourceURL = nil
        }
        guard let source = sourceURL else { return false }
        return importBackgroundImage(from: source)
    }

    /// Records the wallpaper that was set before we ever touched it,
    /// so "Use current wallpaper" still works after Life Calendar takes over.
    func captureOriginalWallpaperIfNeeded() {
        guard originalWallpaperPath.isEmpty else { return }
        guard let screen = NSScreen.main,
              let url = NSWorkspace.shared.desktopImageURL(for: screen),
              !Self.isOurOutput(url: url) else { return }
        originalWallpaperPath = url.path
    }

    private func loadImage(at path: String) -> NSImage? {
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }

    private func copyImageToSupport(from source: URL, prefix: String) -> String? {
        let fm = FileManager.default
        guard let support = try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("LifeCalendar", isDirectory: true) else { return nil }
        try? fm.createDirectory(at: support, withIntermediateDirectories: true)
        let ext = source.pathExtension.isEmpty ? "img" : source.pathExtension
        let dest = support.appendingPathComponent("\(prefix)-\(Int(Date().timeIntervalSince1970)).\(ext)")
        do {
            try fm.copyItem(at: source, to: dest)
            return dest.path
        } catch {
            return nil
        }
    }

    func progress(at date: Date = Date()) -> LifeProgress {
        LifeProgress(
            birthdate: birthdate,
            totalYears: totalYears,
            columns: columns,
            fadeInYears: fadeInYears,
            fadeOutYears: fadeOutYears,
            minScale: minScale,
            minOpacity: minOpacity,
            now: date
        )
    }
}
