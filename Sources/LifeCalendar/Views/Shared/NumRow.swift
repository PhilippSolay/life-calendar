import SwiftUI

/// A `.num-row`: label on the left (12.5pt white 70%), numeric value with optional
/// suffix on the right (22pt light, monospaced, min width 48pt), and two glass
/// icon buttons for decrement / increment. Enforces `range` and `step`.
struct NumRow: View {
    let label: String
    let value: Int
    let suffix: String
    let range: ClosedRange<Int>
    let step: Int
    let onChange: (Int) -> Void

    init(
        label: String,
        value: Int,
        suffix: String = "",
        range: ClosedRange<Int>,
        step: Int = 1,
        onChange: @escaping (Int) -> Void
    ) {
        self.label = label
        self.value = value
        self.suffix = suffix
        self.range = range
        self.step = max(1, step)
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12.5))
                .foregroundStyle(.white.opacity(0.7))

            Spacer(minLength: 8)

            Text("\(value)\(suffix)")
                .font(.system(size: 22, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(minWidth: 48, alignment: .trailing)

            IconButton(text: "−") {
                let next = max(range.lowerBound, value - step)
                if next != value { onChange(next) }
            }
            .opacity(value > range.lowerBound ? 1.0 : 0.4)
            .disabled(value <= range.lowerBound)

            IconButton(text: "+") {
                let next = min(range.upperBound, value + step)
                if next != value { onChange(next) }
            }
            .opacity(value < range.upperBound ? 1.0 : 0.4)
            .disabled(value >= range.upperBound)
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        NumRow(label: "Total years", value: 90, range: 40...130, onChange: { _ in })
        NumRow(label: "Growth", value: 10, suffix: " yrs", range: 0...30, onChange: { _ in })
    }
    .padding(28)
    .frame(width: 360)
    .background(Color.black)
}
