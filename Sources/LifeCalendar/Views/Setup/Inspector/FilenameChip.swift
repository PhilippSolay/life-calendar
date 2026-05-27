import SwiftUI
import AppKit

/// A pill displaying a selected file: a 22 pt rounded thumbnail on the left,
/// the filename in 11 pt monospace, and a circular "×" remove button on the right.
struct FilenameChip: View {
    let name: String
    let thumb: NSImage?
    let onRemove: () -> Void

    init(name: String, thumb: NSImage? = nil, onRemove: @escaping () -> Void) {
        self.name = name
        self.thumb = thumb
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: 10) {
            thumbnail
                .frame(width: 22, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )

            Text(name)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)

            IconButton(text: "×", diameter: 22, action: onRemove)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let thumb = thumb {
            Image(nsImage: thumb)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 22, height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 212.0 / 255.0, green: 160.0 / 255.0, blue: 96.0 / 255.0),
                            Color(red: 110.0 / 255.0, green: 78.0 / 255.0, blue: 144.0 / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        FilenameChip(name: "field.jpg", onRemove: {})
        FilenameChip(name: "really-long-wallpaper-filename-that-truncates.jpg", onRemove: {})
    }
    .padding(40)
    .frame(width: 320)
    .background(Color.black)
}
