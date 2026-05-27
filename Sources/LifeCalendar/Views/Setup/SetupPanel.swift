import SwiftUI

/// The floating glass panel anchored to the right edge of the setup window.
/// 360 pt wide, vertically centered, draggable by the top grip.
struct SetupPanel: View {
    @Binding var selectedTab: SetupTab
    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureDrag: CGSize = .zero

    private let panelWidth: CGFloat = 360

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PanelGrip()
                .gesture(
                    DragGesture()
                        .updating($gestureDrag) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            dragOffset = CGSize(
                                width: dragOffset.width + value.translation.width,
                                height: dragOffset.height + value.translation.height
                            )
                        }
                )

            SetupTabBar(selectedTab: $selectedTab)

            page
                .padding(.top, 4)
        }
        .padding(22)
        .frame(width: panelWidth, alignment: .top)
        .glassPanel(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.7), radius: 40, x: 0, y: 20)
        .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 8)
        .offset(
            x: dragOffset.width + gestureDrag.width,
            y: dragOffset.height + gestureDrag.height
        )
    }

    @ViewBuilder
    private var page: some View {
        switch selectedTab {
        case .lifespan: LifeSpanPage()
        case .style:    StylePage()
        case .layout:   LayoutPage()
        case .save:     SavePage()
        }
    }
}

/// 22 pt tall grip handle at the top of the panel. 36 × 4 pt rounded fill at
/// white 22%, centered horizontally. Cursor hint via help text.
struct PanelGrip: View {
    var body: some View {
        ZStack {
            Color.clear
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .frame(width: 36, height: 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 22)
        .contentShape(Rectangle())
        .help("Drag to move")
    }
}

#Preview {
    StatefulPreviewWrapper(SetupTab.lifespan) { tab in
        SetupPanel(selectedTab: tab)
            .environmentObject(Settings.shared)
            .padding(40)
            .background(Color.black)
    }
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
