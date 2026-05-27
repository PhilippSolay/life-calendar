import SwiftUI
import ServiceManagement

/// Save tab of the setup panel: PNG export, share via email, set as wallpaper,
/// and the LaunchAgent auto-update toggle row.
struct SavePage: View {
    @EnvironmentObject var settings: Settings
    @StateObject private var schedule = ScheduleService.shared
    @StateObject private var presets = PresetStore.shared

    @State private var showingNamePrompt = false
    @State private var draftName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SaveAction(
                label: "Save Wallpaper",
                sub: "Export a PNG to your downloads.",
                action: {
                    if let url = ImageExporter.exportToDownloads(using: settings) {
                        ImageExporter.revealInFinder(url)
                    }
                }
            )

            SaveAction(
                label: "Share via Email",
                sub: "Attach the wallpaper to a new message.",
                action: {
                    ImageExporter.shareViaEmail(using: settings)
                }
            )

            SaveAction(
                label: "Save a preset",
                sub: "Store this look in your Presets tab.",
                action: {
                    draftName = "Preset \(presets.presets.count + 1)"
                    showingNamePrompt = true
                }
            )

            SaveAction(
                label: "Set as Wallpaper",
                sub: "Apply to every connected display.",
                prominent: true,
                action: { WallpaperApply.apply(using: settings) }
            )

            divider

            scheduleRow
        }
        .alert("Name this preset", isPresented: $showingNamePrompt) {
            TextField("Name", text: $draftName)
            Button("Save") {
                let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                let preset = presets.snapshot(from: settings, named: trimmed)
                presets.save(preset)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Saved presets appear under the star tab.")
        }
    }

    // MARK: - Divider

    @ViewBuilder
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.vertical, 6)
    }

    // MARK: - Schedule toggle + helper

    @ViewBuilder
    private var scheduleRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Auto-update at login and daily")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                ScheduleToggle(
                    isOn: schedule.isInstalled,
                    onToggle: { newValue in
                        if newValue {
                            schedule.install()
                        } else {
                            schedule.uninstall()
                        }
                    }
                )
            }

            Text(statusHelperText)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)

            if schedule.status == .requiresApproval {
                GlassButton(size: .sm, action: { schedule.openLoginItems() }) {
                    Text("Open Login Items…")
                }
            }
        }
    }

    private var statusHelperText: String {
        switch schedule.status {
        case .enabled:
            return "Running. Refreshes at login and at 3:00 AM daily."
        case .requiresApproval:
            return "Waiting for approval in System Settings → Login Items."
        case .notRegistered:
            return "Not installed. The wallpaper only updates while the app is open."
        case .notFound:
            return "Schedule plist missing from app bundle."
        @unknown default:
            return "Status unknown."
        }
    }
}

/// Custom toggle matching `.toggle` in styles.css: 32 × 19 pt track with a 15 pt thumb.
/// On: track white 85%, thumb dark. Off: track white 12%, thumb white.
private struct ScheduleToggle: View {
    let isOn: Bool
    let onToggle: (Bool) -> Void

    private let trackWidth: CGFloat = 32
    private let trackHeight: CGFloat = 19
    private let thumbDiameter: CGFloat = 15
    private let inset: CGFloat = 2

    var body: some View {
        // CSS: track 32×19 with thumb travel of 13pt (15pt thumb + 2pt left inset → 30pt → 32-30=2 right gap).
        let travel = trackWidth - thumbDiameter - inset * 2 // 32 - 15 - 4 = 13

        Button {
            onToggle(!isOn)
        } label: {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isOn ? Color.white.opacity(0.85) : Color.white.opacity(0.12))
                    .frame(width: trackWidth, height: trackHeight)

                Circle()
                    .fill(isOn
                          ? Color(red: 20.0 / 255.0, green: 18.0 / 255.0, blue: 33.0 / 255.0)
                          : Color.white)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    .offset(x: inset + (isOn ? travel : 0))
            }
            .frame(width: trackWidth, height: trackHeight)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.2), value: isOn)
    }
}

#Preview {
    SavePage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
