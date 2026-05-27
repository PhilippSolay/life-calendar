import SwiftUI

struct MenuBarContent: View {
    @EnvironmentObject var settings: Settings
    var onOpenSettings: () -> Void
    var onRefresh: () -> Void
    var onOpenOnboarding: () -> Void

    var body: some View {
        let progress = settings.progress()

        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(progress.yearsLived) of \(settings.totalYears)")
                    .font(.system(size: 24, weight: .light))
                    .monospacedDigit()
                Text("years lived")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .glassCard(cornerRadius: 16)

            GlassEffectContainer(spacing: 6) {
                VStack(spacing: 6) {
                    menuButton("Refresh wallpaper", systemImage: "arrow.clockwise", action: onRefresh)
                    menuButton("Settings…", systemImage: "slider.horizontal.3", action: onOpenSettings)
                    menuButton("Show onboarding", systemImage: "sparkles", action: onOpenOnboarding)
                }
            }

            Button(role: .destructive) { NSApp.terminate(nil) } label: {
                Label("Quit Life Calendar", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
        }
        .padding(12)
        .frame(width: 280)
    }

    private func menuButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
    }
}
