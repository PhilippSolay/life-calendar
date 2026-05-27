import SwiftUI

/// Three-step progress indicator used in the Birthday flow: Year → Month → Day.
/// Each stage shows a numbered 18pt chip + uppercased label, with hairline
/// separators between stages.
struct SubProgress: View {
    enum Stage: Int, CaseIterable, Identifiable {
        case year = 1
        case month = 2
        case day = 3

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .year: return "Year"
            case .month: return "Month"
            case .day: return "Day"
            }
        }
    }

    let active: Stage
    let completed: Set<Stage>

    var body: some View {
        HStack(spacing: 14) {
            ForEach(Array(Stage.allCases.enumerated()), id: \.element.id) { (idx, stage) in
                step(stage)
                if idx < Stage.allCases.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 16, height: 1)
                }
            }
        }
    }

    private func step(_ stage: Stage) -> some View {
        let state = state(for: stage)
        return HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(state.chipBackground)
                Text("\(stage.rawValue)")
                    // CSS: chip number `font-size: 10pt; font-weight: 400`.
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(state.chipForeground)
            }
            .frame(width: 18, height: 18)

            Text(stage.label.uppercased())
                .font(.system(size: 11))
                .tracking(0.6)
                .foregroundStyle(state.labelColor)
        }
    }

    private enum StepState {
        case idle, done, active

        var chipBackground: Color {
            switch self {
            case .idle: return Color.white.opacity(0.08)
            case .done: return Color.white.opacity(0.40)
            case .active: return Color.white
            }
        }

        var chipForeground: Color {
            switch self {
            case .idle: return Color.white.opacity(0.65)
            case .done, .active: return Color(red: 20.0 / 255.0, green: 18.0 / 255.0, blue: 33.0 / 255.0)
            }
        }

        var labelColor: Color {
            switch self {
            case .idle: return Color.white.opacity(0.45)
            case .done: return Color.white.opacity(0.95)
            case .active: return Color.white
            }
        }
    }

    private func state(for stage: Stage) -> StepState {
        if stage == active { return .active }
        if completed.contains(stage) { return .done }
        return .idle
    }
}

#Preview {
    VStack(spacing: 24) {
        SubProgress(active: .year, completed: [])
        SubProgress(active: .month, completed: [.year])
        SubProgress(active: .day, completed: [.year, .month])
    }
    .padding(40)
    .background(Color.black)
}
