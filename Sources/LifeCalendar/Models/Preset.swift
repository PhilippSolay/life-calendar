import Foundation

/// A named snapshot of the wallpaper-shaping settings. Image paths are stored
/// verbatim so a preset references the same App Support files the live settings
/// do. Restoring a preset writes these values back into Settings.
struct Preset: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date

    // Grid
    var totalYears: Int
    var columns: Int
    var fadeInYears: Int
    var fadeOutYears: Int
    var minScale: Double
    var minOpacity: Double

    // Layout
    var gridScale: Double
    var gridAnchor: GridAnchor
    var sidePadding: Double

    // Style
    var backgroundHex: String
    var foregroundHex: String
    var backgroundImagePath: String
    var dotImagePath: String
    var backgroundImageMode: BackgroundImageMode
    var dotShape: DotShape
    var iconSize: Double
    var currentYearStyle: CurrentYearStyle
    var currentYearHex: String
    var currentYearImagePath: String
    var gridOpacity: Double

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        totalYears: Int,
        columns: Int,
        fadeInYears: Int,
        fadeOutYears: Int,
        minScale: Double,
        minOpacity: Double,
        gridScale: Double,
        gridAnchor: GridAnchor,
        sidePadding: Double,
        backgroundHex: String,
        foregroundHex: String,
        backgroundImagePath: String,
        dotImagePath: String,
        backgroundImageMode: BackgroundImageMode,
        dotShape: DotShape,
        iconSize: Double,
        currentYearStyle: CurrentYearStyle,
        currentYearHex: String,
        currentYearImagePath: String,
        gridOpacity: Double
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.totalYears = totalYears
        self.columns = columns
        self.fadeInYears = fadeInYears
        self.fadeOutYears = fadeOutYears
        self.minScale = minScale
        self.minOpacity = minOpacity
        self.gridScale = gridScale
        self.gridAnchor = gridAnchor
        self.sidePadding = sidePadding
        self.backgroundHex = backgroundHex
        self.foregroundHex = foregroundHex
        self.backgroundImagePath = backgroundImagePath
        self.dotImagePath = dotImagePath
        self.backgroundImageMode = backgroundImageMode
        self.dotShape = dotShape
        self.iconSize = iconSize
        self.currentYearStyle = currentYearStyle
        self.currentYearHex = currentYearHex
        self.currentYearImagePath = currentYearImagePath
        self.gridOpacity = gridOpacity
    }

    // Defaults for presets saved before these fields existed.
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, totalYears, columns, fadeInYears, fadeOutYears
        case minScale, minOpacity, gridScale, gridAnchor, sidePadding
        case backgroundHex, foregroundHex, backgroundImagePath, dotImagePath
        case backgroundImageMode, dotShape, iconSize, currentYearStyle
        case currentYearHex, currentYearImagePath, gridOpacity
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
        self.totalYears = try c.decode(Int.self, forKey: .totalYears)
        self.columns = try c.decode(Int.self, forKey: .columns)
        self.fadeInYears = try c.decode(Int.self, forKey: .fadeInYears)
        self.fadeOutYears = try c.decode(Int.self, forKey: .fadeOutYears)
        self.minScale = try c.decode(Double.self, forKey: .minScale)
        self.minOpacity = try c.decode(Double.self, forKey: .minOpacity)
        self.gridScale = try c.decode(Double.self, forKey: .gridScale)
        self.gridAnchor = try c.decode(GridAnchor.self, forKey: .gridAnchor)
        self.sidePadding = try c.decode(Double.self, forKey: .sidePadding)
        self.backgroundHex = try c.decode(String.self, forKey: .backgroundHex)
        self.foregroundHex = try c.decode(String.self, forKey: .foregroundHex)
        self.backgroundImagePath = try c.decode(String.self, forKey: .backgroundImagePath)
        self.dotImagePath = try c.decode(String.self, forKey: .dotImagePath)
        self.backgroundImageMode = try c.decode(BackgroundImageMode.self, forKey: .backgroundImageMode)
        self.dotShape = try c.decode(DotShape.self, forKey: .dotShape)
        self.iconSize = try c.decode(Double.self, forKey: .iconSize)
        self.currentYearStyle = try c.decode(CurrentYearStyle.self, forKey: .currentYearStyle)
        self.currentYearHex = try c.decodeIfPresent(String.self, forKey: .currentYearHex)
            ?? "#FFFFFF"
        self.currentYearImagePath = try c.decodeIfPresent(String.self, forKey: .currentYearImagePath)
            ?? ""
        self.gridOpacity = try c.decode(Double.self, forKey: .gridOpacity)
    }
}
