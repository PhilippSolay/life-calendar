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
                .background(WindowConfigurator(mode: .borderlessFullScreen))
        }
        .windowStyle(.hiddenTitleBar)
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

/// Top-level app phase. The window swaps between the birthday onboarding flow
/// and the setup panel.
enum AppPhase: Equatable {
    case birthday
    case setup(tab: SetupTab)
}

struct RootView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var schedule: ScheduleService

    @State private var phase: AppPhase

    init() {
        let initial: AppPhase = Settings.shared.hasOnboarded
            ? .setup(tab: .lifespan)
            : .birthday
        self._phase = State(initialValue: initial)
    }

    var body: some View {
        ZStack {
            switch phase {
            case .birthday:
                BirthdayRoot(onFinish: handleBirthdayFinish)
                    .transition(.opacity)
            case .setup(let tab):
                SetupRoot(initialTab: tab)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.smooth(duration: 0.3), value: phase)
    }

    private func handleBirthdayFinish(_ date: Date) {
        settings.birthdate = date
        settings.hasOnboarded = true
        schedule.install()
        WallpaperApply.apply(using: settings)
        withAnimation(.smooth(duration: 0.3)) {
            phase = .setup(tab: .lifespan)
        }
    }
}
