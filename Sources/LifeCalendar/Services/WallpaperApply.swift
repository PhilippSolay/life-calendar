import AppKit

@MainActor
enum WallpaperApply {
    static func apply(using settings: Settings) {
        let renderer = WallpaperRenderer(settings: settings)
        let setter = WallpaperSetter(renderer: renderer)
        setter.applyToAllScreens()
    }
}
