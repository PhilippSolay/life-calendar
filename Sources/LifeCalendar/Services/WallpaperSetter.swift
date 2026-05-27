import AppKit

@MainActor
struct WallpaperSetter {
    let renderer: WallpaperRenderer

    func applyToAllScreens() {
        renderer.settings.captureOriginalWallpaperIfNeeded()
        for screen in NSScreen.screens {
            do {
                try apply(to: screen)
            } catch {
                NSLog("Life Calendar: failed to set wallpaper on screen \(screen.displayID): \(error.localizedDescription)")
            }
        }
        cleanupOldImages()
    }

    private func apply(to screen: NSScreen) throws {
        let size = screen.frame.size
        let scale = screen.backingScaleFactor
        guard let image = renderer.renderImage(size: size, scale: scale) else {
            throw NSError(domain: "WallpaperSetter", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Render failed"])
        }
        let url = try renderer.outputURL(for: String(screen.displayID))
        try renderer.writeImage(image, to: url)
        try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
    }

    private func cleanupOldImages() {
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("LifeCalendar", isDirectory: true) else { return }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: support,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        let activeURLs = Set(NSScreen.screens.compactMap { NSWorkspace.shared.desktopImageURL(for: $0) })

        for file in contents where file.pathExtension == "png" && !activeURLs.contains(file) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        return (deviceDescription[key] as? NSNumber)?.uint32Value ?? 0
    }
}
