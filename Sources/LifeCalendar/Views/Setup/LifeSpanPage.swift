import SwiftUI

/// Life span tab of the setup panel: section header followed by three
/// numeric rows (total years, fade-in, fade-out).
struct LifeSpanPage: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel("LIFE SPAN")

            VStack(alignment: .leading, spacing: 10) {
                NumRow(
                    label: "Total years",
                    value: settings.totalYears,
                    range: 40...130,
                    onChange: { settings.totalYears = $0 }
                )
                NumRow(
                    label: "Growth",
                    value: settings.fadeInYears,
                    suffix: " yrs",
                    range: 0...30,
                    onChange: { settings.fadeInYears = $0 }
                )
                NumRow(
                    label: "Fade",
                    value: settings.fadeOutYears,
                    suffix: " yrs",
                    range: 0...30,
                    onChange: { settings.fadeOutYears = $0 }
                )
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    LifeSpanPage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
