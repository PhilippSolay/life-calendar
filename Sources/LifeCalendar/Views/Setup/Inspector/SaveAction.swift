import SwiftUI

/// Full-width 56 pt rounded button used on the Save page. Label on the left
/// over a smaller subtitle, trailing chevron on the right. `prominent` swaps
/// the glass background for the bright gradient (white → off-white) with dark text.
struct SaveAction: View {
    let label: String
    let sub: String
    let prominent: Bool
    let action: () -> Void

    init(
        label: String,
        sub: String,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.sub = sub
        self.prominent = prominent
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .inset(by: 0.5)
                .stroke(strokeColor, lineWidth: 1)
        )
        // CSS `0 6pt 20pt -8pt rgba(255,255,255,.4)` — a soft downward white glow.
        .shadow(color: prominent ? Color.white.opacity(0.4) : .clear, radius: 10, x: 0, y: 6)
    }

    @ViewBuilder
    private var content: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(primaryText)
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundStyle(secondaryText)
            }

            Spacer(minLength: 8)

            Text("›")
                .font(.system(size: 18))
                .foregroundStyle(primaryText.opacity(0.7))
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var background: some View {
        if prominent {
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 233.0 / 255.0, green: 231.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.white.opacity(0.07)
        }
    }

    private var primaryText: Color {
        prominent
            ? Color(red: 20.0 / 255.0, green: 18.0 / 255.0, blue: 33.0 / 255.0)
            : .white
    }

    private var secondaryText: Color {
        prominent
            ? Color(red: 20.0 / 255.0, green: 18.0 / 255.0, blue: 33.0 / 255.0).opacity(0.55)
            : Color.white.opacity(0.55)
    }

    private var strokeColor: Color {
        prominent ? Color.white.opacity(0.6) : Color.white.opacity(0.10)
    }
}

#Preview {
    VStack(spacing: 10) {
        SaveAction(label: "Save Wallpaper", sub: "Export a PNG to your downloads.", action: {})
        SaveAction(label: "Share via Email", sub: "Attach the wallpaper to a new message.", action: {})
        SaveAction(label: "Set as Wallpaper", sub: "Apply to every connected display.", prominent: true, action: {})
    }
    .padding(28)
    .frame(width: 360)
    .background(Color.black)
}
