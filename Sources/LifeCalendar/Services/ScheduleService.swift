import Foundation
import ServiceManagement
import AppKit
import Combine

@MainActor
final class ScheduleService: ObservableObject {
    static let shared = ScheduleService()

    private static let plistName = "com.philippsolay.LifeCalendar.plist"

    @Published private(set) var status: SMAppService.Status

    private var agent: SMAppService {
        SMAppService.agent(plistName: Self.plistName)
    }

    init() {
        self.status = SMAppService.agent(plistName: Self.plistName).status
    }

    var isInstalled: Bool { status == .enabled }
    var requiresApproval: Bool { status == .requiresApproval }

    func install() {
        do {
            try agent.register()
        } catch {
            NSLog("Life Calendar: schedule install failed: \(error.localizedDescription)")
        }
        refresh()
    }

    func uninstall() {
        do {
            try agent.unregister()
        } catch {
            NSLog("Life Calendar: schedule uninstall failed: \(error.localizedDescription)")
        }
        refresh()
    }

    func refresh() {
        status = SMAppService.agent(plistName: Self.plistName).status
    }

    func openLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
