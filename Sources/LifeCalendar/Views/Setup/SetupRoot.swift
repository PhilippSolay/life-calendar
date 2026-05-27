import SwiftUI

/// Tabs in the floating setup panel.
enum SetupTab: String, CaseIterable, Identifiable {
    case lifespan, style, layout, save

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lifespan: return "Life span"
        case .style:    return "Style"
        case .layout:   return "Layout"
        case .save:     return "Save"
        }
    }
}

/// Full-bleed setup window: live wallpaper preview behind, traffic lights at the
/// top-left, and the floating settings panel anchored to the right.
struct SetupRoot: View {
    @State private var selectedTab: SetupTab

    init(initialTab: SetupTab = .lifespan) {
        self._selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LiveBackdropView(style: .userWallpaper)
                .ignoresSafeArea()

            TrafficLights()
                .padding(14)

            HStack {
                Spacer()
                SetupPanel(selectedTab: $selectedTab)
                    .padding(.trailing, 36)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SetupRoot(initialTab: .lifespan)
        .environmentObject(Settings.shared)
        .frame(width: 1280, height: 800)
}
