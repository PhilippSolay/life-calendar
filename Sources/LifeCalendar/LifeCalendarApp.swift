import SwiftUI
import AppKit

@main
struct LifeCalendarApp: App {
    @StateObject private var settings = Settings.shared
    @State private var scheduler: Scheduler?

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(
                onOpenSettings: openSettingsWindow,
                onRefresh: applyWallpaper,
                onOpenOnboarding: openOnboardingWindow
            )
            .environmentObject(settings)
            .task { startupIfNeeded() }
        } label: {
            Image(systemName: "circle.grid.3x3.fill")
        }
        .menuBarExtraStyle(.window)
    }

    private func startupIfNeeded() {
        if scheduler == nil {
            let s = Scheduler { applyWallpaper() }
            s.start()
            scheduler = s
        }
        if !settings.hasOnboarded {
            openOnboardingWindow()
        }
    }

    private func applyWallpaper() {
        guard settings.hasOnboarded else { return }
        let renderer = WallpaperRenderer(settings: settings)
        let setter = WallpaperSetter(renderer: renderer)
        setter.applyToAllScreens()
    }

    private func openOnboardingWindow() {
        WindowManager.shared.show(id: "onboarding", title: "Welcome to Life Calendar") {
            AnyView(
                OnboardingView(onFinish: { applyWallpaper() })
                    .environmentObject(settings)
            )
        }
    }

    private func openSettingsWindow() {
        WindowManager.shared.show(id: "settings", title: "Life Calendar Settings") {
            AnyView(
                SettingsView(onApply: { applyWallpaper() })
                    .environmentObject(settings)
            )
        }
    }
}

@MainActor
final class WindowManager {
    static let shared = WindowManager()
    private var windows: [String: NSWindow] = [:]

    func show(id: String, title: String, content: () -> AnyView) {
        if let existing = windows[id] {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let hosting = NSHostingController(rootView: content())
        let window = NSWindow(contentViewController: hosting)
        window.title = title
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.windows.removeValue(forKey: id) }
        }
        windows[id] = window
    }
}
