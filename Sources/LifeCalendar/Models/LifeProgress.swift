import Foundation

enum CellState {
    case lived
    case current
    case remaining
}

struct LifeCell: Identifiable {
    let id: Int
    let yearIndex: Int
    let state: CellState
    let sizeScale: Double
    let opacity: Double
}

struct LifeProgress {
    let birthdate: Date
    let totalYears: Int
    let columns: Int
    let fadeInYears: Int
    let fadeOutYears: Int
    let minScale: Double
    let minOpacity: Double
    let now: Date

    var rows: Int { Int(ceil(Double(totalYears) / Double(columns))) }

    var yearsLived: Int {
        let components = Calendar.current.dateComponents([.year], from: birthdate, to: now)
        return max(0, components.year ?? 0)
    }

    var cells: [LifeCell] {
        (0..<totalYears).map { year in
            LifeCell(
                id: year,
                yearIndex: year,
                state: state(for: year),
                sizeScale: scale(for: year),
                opacity: opacity(for: year)
            )
        }
    }

    private func state(for year: Int) -> CellState {
        if year < yearsLived { return .lived }
        if year == yearsLived { return .current }
        return .remaining
    }

    private func scale(for year: Int) -> Double {
        guard fadeInYears > 0, year < fadeInYears else { return 1.0 }
        let t = Double(year + 1) / Double(fadeInYears)
        return minScale + (1.0 - minScale) * easeInOut(t)
    }

    private func opacity(for year: Int) -> Double {
        guard fadeOutYears > 0 else { return 1.0 }
        let fadeStart = totalYears - fadeOutYears
        guard year >= fadeStart else { return 1.0 }
        let t = Double(year - fadeStart) / Double(fadeOutYears - 1)
        return minOpacity + (1.0 - minOpacity) * (1.0 - easeInOut(t))
    }

    private func easeInOut(_ t: Double) -> Double {
        let clamped = min(max(t, 0.0), 1.0)
        return clamped * clamped * (3.0 - 2.0 * clamped)
    }
}
