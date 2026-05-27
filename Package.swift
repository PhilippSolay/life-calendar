// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LifeCalendar",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "LifeCalendar",
            path: "Sources/LifeCalendar"
        )
    ]
)
