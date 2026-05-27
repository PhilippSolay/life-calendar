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
        self.gridOpacity = gridOpacity
    }
}
