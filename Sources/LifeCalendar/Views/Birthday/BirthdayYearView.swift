import SwiftUI

/// Year picker. 10 columns × N rows, range 1960 → currentYear. Each row is
/// prefixed by a decade label like "60s". Out-of-range cells render as `.dim`.
struct BirthdayYearView: View {
    @ObservedObject var draft: BirthdayDraft
    let onBack: () -> Void
    let onContinue: () -> Void

    private static let yearsStart = 1960
    private static let columnsPerRow = 10
    private static let cellSize: CGFloat = 40
    private static let labelWidth: CGFloat = 44
    private static let cellGap: CGFloat = 6
    private static let cellFont: CGFloat = 13

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    /// Round up so we always fill out the row containing the current year.
    private var rowCount: Int {
        let span = currentYear - Self.yearsStart + 1
        let rows = Int(ceil(Double(span) / Double(Self.columnsPerRow)))
        return max(rows, 1)
    }

    var body: some View {
        BirthdayShell(
            headlineSuffix: nil,
            primaryLabel: "Continue",
            showBack: false,
            stage: .year,
            completed: [],
            continueEnabled: draft.year != nil,
            onBack: onBack,
            onContinue: onContinue
        ) {
            BirthdayCard {
                grid
            }
        }
    }

    private var grid: some View {
        Grid(horizontalSpacing: Self.cellGap, verticalSpacing: Self.cellGap) {
            ForEach(0..<rowCount, id: \.self) { row in
                GridRow {
                    decadeLabel(for: row)
                    ForEach(0..<Self.columnsPerRow, id: \.self) { col in
                        cell(row: row, col: col)
                    }
                }
            }
        }
    }

    private func decadeLabel(for row: Int) -> some View {
        let decade = Self.yearsStart + row * Self.columnsPerRow
        let shortDecade = String(decade).suffix(2)
        return Text("\(shortDecade)s")
            .font(.system(size: 18, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(Color.white)
            .frame(width: Self.labelWidth, height: Self.cellSize, alignment: .trailing)
            .padding(.trailing, 8)
    }

    @ViewBuilder
    private func cell(row: Int, col: Int) -> some View {
        let year = Self.yearsStart + row * Self.columnsPerRow + col
        let isOutOfRange = year > currentYear
        let isSelected = draft.year == year && !isOutOfRange
        let label = isOutOfRange ? "·" : String(String(year).suffix(2))

        CircleCell(
            size: Self.cellSize,
            label: label,
            fontSize: Self.cellFont,
            isSelected: isSelected,
            isDim: isOutOfRange
        ) {
            draft.year = year
        }
    }
}
