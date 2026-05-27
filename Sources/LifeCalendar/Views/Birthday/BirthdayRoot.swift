import SwiftUI

/// Root view for the Birthday flow. Owns the draft and drives the internal
/// stage machine (year → month → day). On the Day screen's Continue, calls the
/// caller-provided `onFinish(date)`.
struct BirthdayRoot: View {
    enum Stage {
        case year, month, day
    }

    @StateObject private var draft = BirthdayDraft()
    @State private var stage: Stage = .year

    let onFinish: (Date) -> Void

    init(onFinish: @escaping (Date) -> Void) {
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            switch stage {
            case .year:
                BirthdayYearView(
                    draft: draft,
                    onBack: {},
                    onContinue: { stage = .month }
                )
            case .month:
                BirthdayMonthView(
                    draft: draft,
                    onBack: { stage = .year },
                    onContinue: { stage = .day }
                )
            case .day:
                BirthdayDayView(
                    draft: draft,
                    onBack: { stage = .month },
                    onFinish: onFinish
                )
            }
        }
        .animation(.smooth(duration: 0.3), value: stage)
    }
}

#Preview {
    BirthdayRoot(onFinish: { date in
        print("Birthday committed: \(date)")
    })
    .environmentObject(Settings.shared)
    .frame(width: 1280, height: 800)
}
