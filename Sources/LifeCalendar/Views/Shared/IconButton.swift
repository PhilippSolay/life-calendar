import SwiftUI

/// Circular glass icon button. Either renders an SF Symbol via `systemName` or
/// a single-character `text` label. Default diameter 26pt matches `.icon-btn`.
struct IconButton: View {
    let systemName: String?
    let text: String?
    let diameter: CGFloat
    let action: () -> Void

    init(
        systemName: String? = nil,
        text: String? = nil,
        diameter: CGFloat = 26,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.text = text
        self.diameter = diameter
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
        }
        .buttonStyle(.glass)
        .clipShape(Circle())
    }

    @ViewBuilder
    private var label: some View {
        // CSS spec: `font-size: 14px; font-weight: 300`. Scale font size with
        // diameter so the 44pt back button reads at ~18pt (matches JSX usage).
        if let systemName = systemName {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.42, weight: .light))
        } else if let text = text {
            Text(text)
                .font(.system(size: diameter * 0.54, weight: .light))
        } else {
            EmptyView()
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        IconButton(systemName: "chevron.left", action: {})
        IconButton(systemName: "chevron.right", diameter: 44, action: {})
        IconButton(text: "−", action: {})
        IconButton(text: "+", action: {})
    }
    .padding(40)
    .background(Color.black)
}
