import SwiftUI
import AppKit
import Combine

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
    static let highlightCurrentYear = "highlightCurrentYear"
    static let backgroundImagePath = "backgroundImagePath"
    static let gridScale = "gridScale"
    static let backgroundImageMode = "backgroundImageMode"
    static let dotImagePath = "dotImagePath"
    static let gridOpacity = "gridOpacity"
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

    @Published var highlightCurrentYear: Bool {
        didSet { defaults.set(highlightCurrentYear, forKey: SettingsKey.highlightCurrentYear) }
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

    init() {
        defaults.register(defaults: [
            SettingsKey.backgroundHex: "#000000",
            SettingsKey.foregroundHex: "#FFFFFF",
            SettingsKey.totalYears: 100,
            SettingsKey.columns: 10,
            SettingsKey.fadeInYears: 10,
            SettingsKey.fadeOutYears: 10,
            SettingsKey.minScale: 0.08,
            SettingsKey.minOpacity: 0.12,
            SettingsKey.highlightCurrentYear: true,
            SettingsKey.backgroundImagePath: "",
            SettingsKey.gridScale: 1.0,
            SettingsKey.backgroundImageMode: BackgroundImageMode.fullScreen.rawValue,
            SettingsKey.dotImagePath: "",
            SettingsKey.gridOpacity: 1.0
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
        self.highlightCurrentYear = defaults.bool(forKey: SettingsKey.highlightCurrentYear)
        self.backgroundImagePath = defaults.string(forKey: SettingsKey.backgroundImagePath) ?? ""
        let storedScale = defaults.double(forKey: SettingsKey.gridScale)
        self.gridScale = storedScale > 0 ? storedScale : 1.0
        let modeRaw = defaults.string(forKey: SettingsKey.backgroundImageMode)
            ?? BackgroundImageMode.fullScreen.rawValue
        self.backgroundImageMode = BackgroundImageMode(rawValue: modeRaw) ?? .fullScreen
        self.dotImagePath = defaults.string(forKey: SettingsKey.dotImagePath) ?? ""
        let storedOpacity = defaults.double(forKey: SettingsKey.gridOpacity)
        self.gridOpacity = storedOpacity > 0 ? storedOpacity : 1.0
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
