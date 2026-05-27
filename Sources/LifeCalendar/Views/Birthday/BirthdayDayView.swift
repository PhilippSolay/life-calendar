import SwiftUI

/// Day picker. 7×5 grid of 56pt circle cells, days beyond the month's last day
/// render as `.dim`. Continue label reads "Continue to setup"; on tap, commits
/// the day to the draft and calls `onFinish(date)`.
struct BirthdayDayView: View {
    @ObservedObject var draft: BirthdayDraft
    let onBack: () -> Void
    let onFinish: (Date) -> Void

    private static let cellSize: CGFloat = 56
    private static let cellGap: CGFloat = 6
    private static let cellFont: CGFloat = 17
    private static let dimFont: CGFloat = 14
    private static let totalCells = 35
    private static let columns = 7

    private var daysInSelectedMonth: Int {
        guard let year = draft.year, let month = draft.month else { return 31 }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let calendar = Calendar.current
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 31
        }
        return range.count
    }

    private var headlineSuffix: String? {
        guard let year = draft.year, let month = draft.month else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = .current
        let monthName = formatter.monthSymbols[month - 1]
        return "\(monthName) \(year)"
    }

    var body: some View {
        BirthdayShell(
            headlineSuffix: headlineSuffix,
            primaryLabel: "Continue to setup",
            showBack: true,
            stage: .day,
            completed: [.year, .month],
            continueEnabled: draft.day != nil,
            onBack: onBack,
            onContinue: commitAndFinish
        ) {
            BirthdayCard {
                grid
            }
        }
    }

    private var grid: some View {
        let columns = Array(
            repeating: GridItem(.fixed(Self.cellSize), spacing: Self.cellGap),
            count: Self.columns
        )
        return LazyVGrid(columns: columns, spacing: Self.cellGap) {
            ForEach(0..<Self.totalCells, id: \.self) { idx in
                cell(at: idx)
            }
        }
    }

    @ViewBuilder
    private func cell(at idx: Int) -> some View {
        let day = idx + 1
        let isOutOfMonth = day > daysInSelectedMonth
        let isSelected = draft.day == day && !isOutOfMonth
        let label = isOutOfMonth ? "·" : String(day)
        let fontSize: CGFloat = isOutOfMonth ? Self.dimFont : Self.cellFont

        CircleCell(
            size: Self.cellSize,
            label: label,
            fontSize: fontSize,
            isSelected: isSelected,
            isDim: isOutOfMonth
        ) {
            draft.day = day
        }
    }

    private func commitAndFinish() {
        guard let date = draft.committedDate() else { return }
        onFinish(date)
    }
}
