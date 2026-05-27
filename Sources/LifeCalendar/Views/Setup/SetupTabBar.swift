import SwiftUI

/// Pill-shaped horizontal selector with four tabs. Matches `.panel-tabs` styling:
/// 4 pt outer padding, capsule shape, white-4% background with an inset hairline.
/// Selected tab gets a white-10% background and full-strength text.
struct SetupTabBar: View {
    @Binding var selectedTab: SetupTab
    let onBirthdayRequested: (() -> Void)?

    init(selectedTab: Binding<SetupTab>, onBirthdayRequested: (() -> Void)? = nil) {
        self._selectedTab = selectedTab
        self.onBirthdayRequested = onBirthdayRequested
    }

    private let outerPadding: CGFloat = 4
    private let buttonHeight: CGFloat = 28

    var body: some View {
        HStack(spacing: 0) {
            if let onBirthdayRequested {
                Button(action: onBirthdayRequested) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .frame(width: 36, height: buttonHeight)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("Edit birthdate")
            }

            ForEach(SetupTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(outerPadding)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            Capsule()
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func tabButton(for tab: SetupTab) -> some View {
        let isSelected = tab == selectedTab
        Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            label(for: tab, isSelected: isSelected)
                .frame(maxWidth: tab.icon != nil ? 36 : .infinity)
                .frame(height: buttonHeight)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    Capsule()
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                        .mask(
                                            LinearGradient(
                                                colors: [Color.white, Color.clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                )
                        }
                    }
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func label(for tab: SetupTab, isSelected: Bool) -> some View {
        if let icon = tab.icon {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.65))
        } else if let text = tab.label {
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.65))
        }
    }
}

#Preview {
    StatefulPreviewWrapper(SetupTab.lifespan) { tab in
        SetupTabBar(selectedTab: tab)
            .padding(22)
            .frame(width: 360)
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
