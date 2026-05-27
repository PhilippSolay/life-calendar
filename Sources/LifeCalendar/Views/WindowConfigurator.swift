import SwiftUI
import AppKit

struct WindowConfigurator: NSViewRepresentable {
    let showTrafficLights: Bool

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
            for button in buttons {
                window.standardWindowButton(button)?.isHidden = !showTrafficLights
            }
        }
    }
}
