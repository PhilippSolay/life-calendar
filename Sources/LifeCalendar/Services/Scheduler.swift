import AppKit
import Combine

@MainActor
final class Scheduler {
    private let onTick: () -> Void
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []

    init(onTick: @escaping () -> Void) {
        self.onTick = onTick
    }

    func start() {
        scheduleDailyTimer()
        observeScreenChanges()
        observeWake()
        onTick()
    }

    private func scheduleDailyTimer() {
        timer?.invalidate()
        let interval: TimeInterval = 24 * 60 * 60
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.onTick() }
        }
    }

    private func observeScreenChanges() {
        let token = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.onTick() }
        }
        observers.append(token)
    }

    private func observeWake() {
        let token = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.onTick() }
        }
        observers.append(token)
    }

    isolated deinit {
        timer?.invalidate()
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
