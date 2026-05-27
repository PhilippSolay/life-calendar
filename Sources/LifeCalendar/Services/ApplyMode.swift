import AppKit
import os

@MainActor
enum ApplyMode {
    private static let log = Logger(subsystem: "com.philippsolay.LifeCalendar", category: "apply")

    static func run() {
        let settings = Settings.shared
        guard settings.hasOnboarded else {
            log.info("Skipped --apply: onboarding not complete")
            return
        }
        log.info("Applying wallpaper headlessly")
        WallpaperApply.apply(using: settings)
    }
}
