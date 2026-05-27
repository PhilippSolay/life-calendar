import SwiftUI

extension View {
    /// Standard light glass card. Used for the default `.glass--md` look
    /// (rgba(255,255,255,.045) tinted, 20pt blur).
    func glassCard(cornerRadius: CGFloat = 22) -> some View {
        glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Dark "panel" glass — rgba(20,18,30,.55). Used by the floating Setup panel.
    /// Achieved by tinting the regular glass effect with a dark, mostly-opaque colour.
    func glassPanel(cornerRadius: CGFloat = 22) -> some View {
        glassEffect(
            .regular.tint(Color(red: 20.0 / 255.0, green: 18.0 / 255.0, blue: 30.0 / 255.0).opacity(0.55)),
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}
