import SwiftUI

/// A pill-shaped Liquid Glass button matching the design system's
/// `.btn--xl / --lg / --sm` sizes. Wraps `.buttonStyle(.glass)` /
/// `.buttonStyle(.glassProminent)` with capsule shape and design-system metrics.
struct GlassButton<Label: View>: View {
    enum Size {
        case xl, lg, sm

        var height: CGFloat {
            switch self {
            case .xl: return 44
            case .lg: return 36
            case .sm: return 26
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .xl: return 22
            case .lg: return 18
            case .sm: return 12
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .xl: return 14.5
            case .lg: return 13.5
            case .sm: return 12
            }
        }
    }

    let size: Size
    let prominent: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    init(
        size: Size = .xl,
        prominent: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.size = size
        self.prominent = prominent
        self.action = action
        self.label = label
    }

    var body: some View {
        if prominent {
            Button(action: action) {
                styledLabel
            }
            .buttonStyle(.glassProminent)
            .clipShape(Capsule())
        } else {
            Button(action: action) {
                styledLabel
            }
            .buttonStyle(.glass)
            .clipShape(Capsule())
        }
    }

    private var styledLabel: some View {
        label()
            // CSS spec: both `.btn--glass` and `.btn--glass-prom` use font-weight 400.
            .font(.system(size: size.fontSize, weight: .regular))
            .tracking(-0.1)
            .padding(.horizontal, size.horizontalPadding)
            .frame(height: size.height)
            .contentShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassButton(size: .xl, prominent: true, action: {}) { Text("Continue") }
        GlassButton(size: .xl, action: {}) { Text("Back") }
        GlassButton(size: .lg, action: {}) { Text("Use current") }
        GlassButton(size: .sm, action: {}) { Text("Select image…") }
    }
    .padding(40)
    .background(Color.black)
}
