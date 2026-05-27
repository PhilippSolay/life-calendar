import SwiftUI

/// Tabs in the floating setup panel.
enum SetupTab: String, CaseIterable, Identifiable {
    case presets, lifespan, layout, style, save

    var id: String { rawValue }

    /// Text label, or nil if the tab uses an SF Symbol icon instead.
    var label: String? {
        switch self {
        case .lifespan: return "Life span"
        case .style:    return "Style"
        case .layout:   return "Layout"
        case .presets:  return nil
        case .save:     return "Save"
        }
    }

    /// SF Symbol name, used for icon-only tabs.
    var icon: String? {
        switch self {
        case .presets: return "star"
        default:       return nil
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
