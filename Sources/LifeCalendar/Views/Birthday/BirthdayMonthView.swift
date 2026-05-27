import SwiftUI

/// Month picker. 4 columns × 3 rows of 88pt circle cells.
struct BirthdayMonthView: View {
    @ObservedObject var draft: BirthdayDraft
    let onBack: () -> Void
    let onContinue: () -> Void

    private static let cellSize: CGFloat = 88
    private static let cellGap: CGFloat = 12
    private static let cellFont: CGFloat = 15

    private static let monthLabels = [
        "Jan", "Feb", "Mar", "Apr",
        "May", "Jun", "Jul", "Aug",
        "Sep", "Oct", "Nov", "Dec"
    ]

    private var headlineSuffix: String? {
        guard let year = draft.year else { return nil }
        return String(year)
    }

    var body: some View {
        BirthdayShell(
            headlineSuffix: headlineSuffix,
            primaryLabel: "Continue",
            showBack: true,
            stage: .month,
            completed: [.year],
            continueEnabled: draft.month != nil,
            onBack: onBack,
            onContinue: onContinue
        ) {
            BirthdayCard {
                grid
            }
        }
    }

    private var grid: some View {
        let columns = Array(
            repeating: GridItem(.fixed(Self.cellSize), spacing: Self.cellGap),
            count: 4
        )
        return LazyVGrid(columns: columns, spacing: Self.cellGap) {
            ForEach(0..<12, id: \.self) { idx in
                let monthNumber = idx + 1
                CircleCell(
                    size: Self.cellSize,
                    label: Self.monthLabels[idx],
                    fontSize: Self.cellFont,
                    isSelected: draft.month == monthNumber
                ) {
                    draft.month = monthNumber
                }
            }
        }
    }
}
