import SwiftUI

/// 30 pt tall pill button with a 14 pt color swatch + label. Tapping the chip
/// opens the system color picker — implemented by overlaying SwiftUI's native
/// `ColorPicker` with its swatch styled to match the design.
struct ColorChip: View {
    let label: String
    @Binding var hex: String

    init(label: String = "Color", hex: Binding<String>) {
        self.label = label
        self._hex = hex
    }

    var body: some View {
        ZStack {
            // The visual chip — purely cosmetic; the native ColorPicker overlaid
            // on top owns the actual hit testing.
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color(hex: hex))
                    .frame(width: 14, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )

                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.07))
            )
            .overlay(
                Capsule()
                    .inset(by: 0.5)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(Capsule())

            // Native ColorPicker — invisible swatch, hidden label, sized to match
            // the chip so tapping anywhere opens the system color sheet.
            ColorPicker(
                "",
                selection: Binding(
                    get: { Color(hex: hex) },
                    set: { newColor in
                        if let newHex = ColorChip.hexString(from: newColor) {
                            hex = newHex
                        }
                    }
                ),
                supportsOpacity: false
            )
            .labelsHidden()
            .opacity(0.02) // Effectively invisible but still hit-testable.
            .frame(width: 80, height: 30)
        }
        .frame(height: 30)
    }

    /// Convert a SwiftUI `Color` to a `#RRGGBB` string via NSColor in sRGB space.
    private static func hexString(from color: Color) -> String? {
        let nsColor = NSColor(color)
        guard let converted = nsColor.usingColorSpace(.sRGB) else { return nil }
        let r = Int(round(converted.redComponent * 255))
        let g = Int(round(converted.greenComponent * 255))
        let b = Int(round(converted.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    StatefulPreviewWrapper("#0a0a0a") { hex in
        VStack(spacing: 12) {
            ColorChip(label: "Color", hex: hex)
            ColorChip(label: "Color", hex: hex)
        }
        .padding(40)
        .background(Color.black)
    }
}

/// Minimal stateful preview helper used in previews above.
private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
