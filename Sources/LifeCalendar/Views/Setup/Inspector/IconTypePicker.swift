import SwiftUI

/// Segmented control with three SVG-equivalent shape glyphs:
/// circle / rounded square / square. Filled when selected,
/// 1.4 pt stroked when not. Matches `.segmented` styling.
struct IconTypePicker: View {
    let value: DotShape
    let onChange: (DotShape) -> Void

    init(value: DotShape, onChange: @escaping (DotShape) -> Void) {
        self.value = value
        self.onChange = onChange
    }

    private let buttonHeight: CGFloat = 26
    private let buttonRadius: CGFloat = 6
    private let outerPadding: CGFloat = 3
    private let outerRadius: CGFloat = 8

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DotShape.allCases) { shape in
                button(for: shape)
            }
        }
        .padding(outerPadding)
        .background(
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func button(for shape: DotShape) -> some View {
        let isOn = value == shape
        Button {
            onChange(shape)
        } label: {
            glyph(for: shape, filled: isOn)
                .frame(minWidth: 38)
                .frame(height: buttonHeight)
                .background(
                    Group {
                        if isOn {
                            RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: buttonRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isOn)
    }

    @ViewBuilder
    private func glyph(for shape: DotShape, filled: Bool) -> some View {
        let size: CGFloat = 18
        let stroke: CGFloat = 1.4

        switch shape {
        case .circle:
            if filled {
                Circle()
                    .fill(Color.white)
                    .frame(width: size - 6, height: size - 6) // r=6 in 18pt box ⇒ d=12
            } else {
                Circle()
                    .stroke(Color.white, lineWidth: stroke)
                    .frame(width: size - 6, height: size - 6)
            }
        case .roundedSquare:
            // 12pt rect with rx=3.5 inside 18pt box. Same ratio at 12pt: ~3.5.
            let cornerRadius: CGFloat = 3.5
            if filled {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white)
                    .frame(width: size - 6, height: size - 6)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white, lineWidth: stroke)
                    .frame(width: size - 6, height: size - 6)
            }
        case .square:
            let cornerRadius: CGFloat = 0.5
            if filled {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white)
                    .frame(width: size - 6, height: size - 6)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white, lineWidth: stroke)
                    .frame(width: size - 6, height: size - 6)
            }
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        IconTypePicker(value: .circle, onChange: { _ in })
        IconTypePicker(value: .roundedSquare, onChange: { _ in })
        IconTypePicker(value: .square, onChange: { _ in })
    }
    .padding(40)
    .background(Color.black)
}
