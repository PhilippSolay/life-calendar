import SwiftUI

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
