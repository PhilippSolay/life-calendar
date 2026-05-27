import SwiftUI
import AppKit

struct LifeCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = Settings.shared
    @StateObject private var schedule = ScheduleService.shared

    var body: some Scene {
        Window("Life Calendar", id: "main") {
            RootView()
                .environmentObject(settings)
                .environmentObject(schedule)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

struct RootView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var schedule: ScheduleService

    var body: some View {
        Group {
            if settings.hasOnboarded {
                SettingsView(onApply: applyWallpaper)
            } else {
                OnboardingView(onFinish: completeOnboarding)
            }
        }
    }

    private func applyWallpaper() {
        WallpaperApply.apply(using: settings)
    }

    private func completeOnboarding() {
        applyWallpaper()
        schedule.install()
    }
}
