import SwiftUI
import AppKit

@MainActor
struct WallpaperRenderer {
    let settings: Settings

    func renderImage(size: CGSize, scale: CGFloat) -> NSImage? {
        let view = LifeGridView(
            progress: settings.progress(),
            backgroundColor: Color(hex: settings.backgroundHex),
            foregroundColor: Color(hex: settings.foregroundHex),
            highlightCurrentYear: settings.highlightCurrentYear,
            backgroundImage: settings.backgroundImage,
            gridScale: settings.gridScale,
            backgroundImageMode: settings.backgroundImageMode,
            dotImage: settings.dotImage,
            gridOpacity: settings.gridOpacity
        )
        .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(size)
        return renderer.nsImage
    }

    func writeImage(_ image: NSImage, to url: URL) throws {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "WallpaperRenderer", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
        }
        try png.write(to: url, options: .atomic)
    }

    func outputURL(for screenID: String) throws -> URL {
        let support = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("LifeCalendar", isDirectory: true)
        try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        let stamp = Int(Date().timeIntervalSince1970)
        return support.appendingPathComponent("wallpaper-\(screenID)-\(stamp).png")
    }
}
