import SwiftUI

/// Per-screen layout for the Birthday flow. Layers a LiveBackdrop behind a
/// vertical content stack of: headline → card content → SubProgress → footer.
///
/// The footer is a centered HStack: 44pt Back IconButton (transparent spacer
/// when `showBack == false`), prominent xl GlassButton Continue, and a 44pt
/// spacer on the right to keep Continue visually centered.
struct BirthdayShell<CardContent: View>: View {
    let headlineSuffix: String?
    let primaryLabel: String
    let showBack: Bool
    let stage: SubProgress.Stage
    let completed: Set<SubProgress.Stage>
    let continueEnabled: Bool
    let onBack: () -> Void
    let onContinue: () -> Void
    @ViewBuilder let card: () -> CardContent

    init(
        headlineSuffix: String? = nil,
        primaryLabel: String = "Continue",
        showBack: Bool = true,
        stage: SubProgress.Stage,
        completed: Set<SubProgress.Stage>,
        continueEnabled: Bool,
        onBack: @escaping () -> Void = {},
        onContinue: @escaping () -> Void,
        @ViewBuilder card: @escaping () -> CardContent
    ) {
        self.headlineSuffix = headlineSuffix
        self.primaryLabel = primaryLabel
        self.showBack = showBack
        self.stage = stage
        self.completed = completed
        self.continueEnabled = continueEnabled
        self.onBack = onBack
        self.onContinue = onContinue
        self.card = card
    }

    var body: some View {
        ZStack {
            LiveBackdropView(showPreviewGrid: false)

            VStack(spacing: 40) {
                headline
                card()
                SubProgress(active: stage, completed: completed)
                footer
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 56)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Headline

    private var headline: some View {
        // CSS spec only adds a 12pt gap before the suffix when there is one; the
        // standalone ellipsis butts up against "I was born". Build the text in a
        // single line so kerning behaves like the JSX reference.
        Group {
            if let suffix = headlineSuffix, !suffix.isEmpty {
                HStack(spacing: 12) {
                    Text("I was born")
                        .font(.system(size: 40, weight: .light))
                    Text(suffix)
                        .font(.system(size: 40, weight: .semibold))
                }
            } else {
                Text("I was born…")
                    .font(.system(size: 40, weight: .light))
            }
        }
        .foregroundStyle(Color.white)
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 2)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 14) {
            if showBack {
                IconButton(systemName: "chevron.left", diameter: 44, action: onBack)
            } else {
                // Transparent spacer keeps Continue visually centered.
                Color.clear.frame(width: 44, height: 44)
            }

            GlassButton(size: .xl, prominent: true, action: onContinue) {
                Text(primaryLabel)
            }
            .opacity(continueEnabled ? 1 : 0.5)
            .disabled(!continueEnabled)

            Color.clear.frame(width: 44, height: 44)
        }
    }
}
