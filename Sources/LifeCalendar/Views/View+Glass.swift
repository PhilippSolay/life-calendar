import SwiftUI

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func glassPanel(cornerRadius: CGFloat = 16) -> some View {
        glassEffect(.regular.tint(.black.opacity(0.06)), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func glassCircle() -> some View {
        glassEffect(.regular, in: Circle())
    }
}
