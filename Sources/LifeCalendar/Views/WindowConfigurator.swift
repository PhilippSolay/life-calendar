import SwiftUI
import AppKit

struct WindowConfigurator: NSViewRepresentable {
    enum Mode {
        case borderlessFullScreen
        case standard
    }

    let mode: Mode

    init(mode: Mode = .borderlessFullScreen) {
        self.mode = mode
    }

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            switch mode {
            case .borderlessFullScreen:
                window.styleMask = [.borderless, .fullSizeContentView]
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = false
                if let screen = NSScreen.main {
                    window.setFrame(screen.frame, display: true)
                }
                window.level = .normal
                let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
                for button in buttons {
                    window.standardWindowButton(button)?.isHidden = true
                }
            case .standard:
                window.titlebarAppearsTransparent = false
                window.titleVisibility = .visible
                window.isMovableByWindowBackground = false
                let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
                for button in buttons {
                    window.standardWindowButton(button)?.isHidden = false
                }
            }
        }
    }
}
