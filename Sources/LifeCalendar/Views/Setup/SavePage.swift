import SwiftUI
import AppKit

/// Save tab: export / share / preset / set-as-wallpaper actions plus a Done
/// button to quit the configurator. The LaunchAgent still installs silently
/// on first onboarding completion — it's just no longer surfaced as a toggle.
struct SavePage: View {
    @EnvironmentObject var settings: Settings
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

            doneButton
                .padding(.top, 6)
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

    // MARK: - Done button

    @ViewBuilder
    private var doneButton: some View {
        HStack {
            Spacer()
            GlassButton(size: .lg, action: { NSApp.terminate(nil) }) {
                Text("Done")
            }
            Spacer()
        }
    }
}

#Preview {
    SavePage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
