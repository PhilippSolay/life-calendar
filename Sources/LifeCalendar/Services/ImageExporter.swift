import AppKit
import SwiftUI

/// Renders the wallpaper PNG to disk. Two destinations:
/// - `exportToDownloads` writes a dated file in ~/Downloads and returns the URL
/// - `exportToTemp` writes to a temp file (for sharing via NSSharingService)
@MainActor
enum ImageExporter {
    /// Render at the main screen's native resolution × backingScaleFactor.
    static func renderPNG(using settings: Settings) -> Data? {
        let renderer = WallpaperRenderer(settings: settings)
        guard let screen = NSScreen.main else { return nil }
        let size = screen.frame.size
        let scale = screen.backingScaleFactor
        guard let image = renderer.renderImage(size: size, scale: scale) else { return nil }

        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else { return nil }
        return png
    }

    static func exportToDownloads(using settings: Settings) -> URL? {
        guard let png = renderPNG(using: settings) else { return nil }

        let fm = FileManager.default
        guard let downloads = try? fm.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let stamp = formatter.string(from: Date())
        let dest = downloads.appendingPathComponent("Life Calendar \(stamp).png")

        do {
            try png.write(to: dest, options: .atomic)
            return dest
        } catch {
            NSLog("Life Calendar: PNG export failed: \(error.localizedDescription)")
            return nil
        }
    }

    static func exportToTemp(using settings: Settings) -> URL? {
        guard let png = renderPNG(using: settings) else { return nil }

        let fm = FileManager.default
        let temp = fm.temporaryDirectory.appendingPathComponent(
            "LifeCalendar-share-\(Int(Date().timeIntervalSince1970)).png"
        )

        do {
            try png.write(to: temp, options: .atomic)
            return temp
        } catch {
            NSLog("Life Calendar: PNG temp export failed: \(error.localizedDescription)")
            return nil
        }
    }

    static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Opens the user's default email client with the rendered PNG attached.
    /// Uses NSSharingService(.composeEmail) so the Mail app composes a new message.
    static func shareViaEmail(using settings: Settings) {
        guard let url = exportToTemp(using: settings) else { return }
        guard let service = NSSharingService(named: .composeEmail) else { return }
        service.subject = "Life Calendar"
        service.perform(withItems: [url])
    }
}
