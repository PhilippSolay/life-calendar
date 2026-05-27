import SwiftUI

/// 3 × 3 grid of small rounded-rectangle buttons representing the nine
/// `GridAnchor` positions. Each swatch is 36 × 22 pt with a 5 pt radius.
/// Selected: white fill + soft drop shadow + inset top highlight.
/// Unselected: white-4% background with an inset hairline stroke.
struct PositionSwatches: View {
    let value: Int
    let onChange: (Int) -> Void

    private let swatchSize = CGSize(width: 36, height: 22)
    private let swatchRadius: CGFloat = 5
    private let gap: CGFloat = 8

    init(value: Int, onChange: @escaping (Int) -> Void) {
        self.value = value
        self.onChange = onChange
    }

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        swatch(for: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func swatch(for index: Int) -> some View {
        let isSelected = index == value
        Button {
            onChange(index)
        } label: {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: swatchRadius, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: swatchRadius, style: .continuous)
                                .inset(by: 0.5)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                // Top-only highlight, approximated by an inset stroke.
                                .mask(
                                    LinearGradient(
                                        colors: [Color.white, Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                } else {
                    RoundedRectangle(cornerRadius: swatchRadius, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: swatchRadius, style: .continuous)
                                .inset(by: 0.5)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                }
            }
            .frame(width: swatchSize.width, height: swatchSize.height)
            .contentShape(RoundedRectangle(cornerRadius: swatchRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.15), value: isSelected)
    }
}

#Preview {
    PositionSwatches(value: 4, onChange: { _ in })
        .padding(40)
        .background(Color.black)
}
