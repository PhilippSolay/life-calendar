import AppKit

let arguments = CommandLine.arguments

if arguments.contains("--apply") {
    let app = NSApplication.shared
    app.setActivationPolicy(.prohibited)

    MainActor.assumeIsolated {
        ApplyMode.run()
    }
    exit(0)
}

LifeCalendarApp.main()
