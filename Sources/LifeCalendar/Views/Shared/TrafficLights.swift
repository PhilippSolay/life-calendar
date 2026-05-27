import SwiftUI

/// Monochrome traffic-light dots used in the top-left corner of borderless windows.
/// Purely decorative — buttons aren't wired up; the real window controls are hidden
/// by `WindowConfigurator(mode: .borderlessFullScreen)`.
struct TrafficLights: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        Circle()
                            .inset(by: 0.5)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .frame(width: 12, height: 12)
            }
        }
    }
}

#Preview {
    TrafficLights()
        .padding()
        .background(Color.black)
}
