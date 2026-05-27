import SwiftUI

/// Full-width 56 pt rounded button used on the Save page. Label on the left
/// over a smaller subtitle, trailing chevron on the right. `prominent` swaps
/// the glass background for the bright gradient (white → off-white) with dark text.
///
/// The button shows a visible "active" state on press: subtle scale down,
/// brighter background, brighter stroke, brighter shadow on the prominent
/// variant. Driven by `SaveActionButtonStyle.Configuration.isPressed`.
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
        .buttonStyle(SaveActionButtonStyle(prominent: prominent))
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
}

private struct SaveActionButtonStyle: ButtonStyle {
    let prominent: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(strokeColor(pressed: configuration.isPressed), lineWidth: 1)
            )
            // CSS `0 6pt 20pt -8pt rgba(255,255,255,.4)` — soft downward white glow.
            .shadow(
                color: shadowColor(pressed: configuration.isPressed),
                radius: configuration.isPressed ? 14 : 10,
                x: 0,
                y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.smooth(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private func background(pressed: Bool) -> some View {
        if prominent {
            LinearGradient(
                stops: [
                    .init(color: pressed ? Color(white: 0.94) : .white, location: 0.0),
                    .init(
                        color: Color(
                            red: 233.0 / 255.0,
                            green: 231.0 / 255.0,
                            blue: 226.0 / 255.0
                        ),
                        location: 1.0
                    )
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.white.opacity(pressed ? 0.16 : 0.07)
        }
    }

    private func strokeColor(pressed: Bool) -> Color {
        if prominent {
            return Color.white.opacity(pressed ? 0.85 : 0.6)
        }
        return Color.white.opacity(pressed ? 0.22 : 0.10)
    }

    private func shadowColor(pressed: Bool) -> Color {
        guard prominent else { return .clear }
        return Color.white.opacity(pressed ? 0.55 : 0.4)
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
