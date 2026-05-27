import Foundation
import SwiftUI

/// Mutable draft for the birthday flow. Holds the three independent selections
/// (year / month / day) until the user finishes the flow, at which point we
/// validate via `committedDate(calendar:)` and commit to Settings.
@MainActor
final class BirthdayDraft: ObservableObject {
    @Published var year: Int?
    @Published var month: Int?
    @Published var day: Int?

    init(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Returns the validated `Date` or `nil` when any field is missing or
    /// the combination is invalid (e.g. Feb 31).
    func committedDate(calendar: Calendar = .current) -> Date? {
        guard let year = year, let month = month, let day = day else { return nil }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        // `date(from:)` returns nil for invalid combinations only when the
        // calendar's strict-ness is set; we explicitly verify the round-trip.
        guard let date = calendar.date(from: components) else { return nil }
        let roundTrip = calendar.dateComponents([.year, .month, .day], from: date)
        guard roundTrip.year == year, roundTrip.month == month, roundTrip.day == day else {
            return nil
        }
        return date
    }
}
