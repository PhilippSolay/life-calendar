import SwiftUI

/// Circular grid cell used across the Birthday flow's year, month, and day
/// pickers. Mirrors `.cell-circle` from `styles.css`:
///
/// - Disc size animates from `size` (idle/hover) to 56pt when selected.
/// - Idle bg transparent; hover bg `white .08`; selected white with shadow and
///   inset highlight.
/// - Label flips from white 95% (light) to `rgb(20, 18, 33)` (regular) when
///   selected.
/// - `.dim` variant: label white 22%, no hover, no taps.
struct CircleCell: View {
    let size: CGFloat
    let label: String
    let fontSize: CGFloat
    let isSelected: Bool
    var isDim: Bool = false
    let onTap: () -> Void

    @State private var isHovering: Bool = false

    /// Selected-state disc is always 56pt regardless of incoming `size`.
    private static let selectedDiameter: CGFloat = 56

    /// Dark ink used as the label colour on a selected (white) disc.
    private static let selectedInk = Color(red: 20.0 / 255.0,
                                           green: 18.0 / 255.0,
                                           blue: 33.0 / 255.0)

    private static let discAnimation: Animation = .timingCurve(0.3, 0.7, 0.3, 1, duration: 0.2)

    var body: some View {
        Button(action: tap) {
            ZStack {
                disc
                labelView
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDim)
        .allowsHitTesting(!isDim)
        .onHover { hovering in
            guard !isDim else { return }
            isHovering = hovering
        }
        .animation(Self.discAnimation, value: isSelected)
        .animation(Self.discAnimation, value: isHovering)
    }

    private func tap() {
        guard !isDim else { return }
        onTap()
    }

    // MARK: - Disc — a single morphing Circle whose width/height + fill animate,
    // matching the CSS `transition: width .2s ..., height .2s ..., background`.

    private var discDiameter: CGFloat {
        isSelected ? Self.selectedDiameter : size
    }

    private var discFill: Color {
        if isSelected { return .white }
        if isHovering && !isDim { return Color.white.opacity(0.08) }
        return .clear
    }

    @ViewBuilder
    private var disc: some View {
        ZStack {
            Circle()
                .fill(discFill)
                // CSS: `0 4px 14px rgba(0,0,0,.45)` only when selected.
                .shadow(
                    color: isSelected ? Color.black.opacity(0.45) : .clear,
                    radius: isSelected ? 7 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
            if isSelected {
                // CSS `inset 0 1px 0 rgba(255,255,255,.6)` — a top-only glint,
                // not a full ring. Mask a 1pt strokeBorder to the top half so
                // it reads as a highlight rather than an outline.
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                    .mask(
                        LinearGradient(
                            colors: [Color.white, Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        }
        .frame(width: discDiameter, height: discDiameter)
    }

    // MARK: - Label

    private var labelView: some View {
        Text(label)
            .font(.system(size: fontSize, weight: isSelected ? .regular : .light))
            .foregroundStyle(labelColor)
            .monospacedDigit()
    }

    private var labelColor: Color {
        if isSelected { return Self.selectedInk }
        if isDim { return Color.white.opacity(0.22) }
        return Color.white.opacity(0.95)
    }
}

#Preview {
    HStack(spacing: 24) {
        CircleCell(size: 40, label: "77", fontSize: 13, isSelected: false, onTap: {})
        CircleCell(size: 40, label: "77", fontSize: 13, isSelected: true, onTap: {})
        CircleCell(size: 40, label: "·", fontSize: 13, isSelected: false, isDim: true, onTap: {})
        CircleCell(size: 56, label: "22", fontSize: 17, isSelected: true, onTap: {})
        CircleCell(size: 88, label: "Mar", fontSize: 15, isSelected: true, onTap: {})
    }
    .padding(40)
    .background(Color.black)
}
