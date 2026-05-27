import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct OnboardingView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) private var dismiss
    var onFinish: () -> Void

    @State private var step: Step = .birthdate

    enum Step: Int, CaseIterable, Identifiable {
        case birthdate, lifespan, look, save
        var id: Int { rawValue }

        var icon: String {
            switch self {
            case .birthdate: return "calendar"
            case .lifespan: return "circle.grid.3x3"
            case .look: return "paintbrush"
            case .save: return "checkmark.seal"
            }
        }

        var title: String {
            switch self {
            case .birthdate: return "When were you born?"
            case .lifespan: return "Your lifespan"
            case .look: return "Make it yours"
            case .save: return "Ready"
            }
        }

        var subtitle: String {
            switch self {
            case .birthdate: return "Every dot in your calendar is anchored to this date."
            case .lifespan: return "How many years should the grid hold, and how should the edges fade?"
            case .look: return "Background, dots, and how the grid sits on your desktop."
            case .save: return "Set your wallpaper now. Everything stays editable from the menu bar."
            }
        }
    }

    var body: some View {
        ZStack {
            backdrop.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 36)

                header
                    .padding(.bottom, 28)

                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 44)

                progressIndicator
                    .padding(.top, 24)
                    .padding(.bottom, 18)

                footer
                    .padding(.bottom, 28)
                    .padding(.horizontal, 44)
            }
        }
        .frame(width: 920, height: 920)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
    }

    private var backdrop: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.07, blue: 0.13),
                    Color(red: 0.02, green: 0.02, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.white.opacity(0.08), .clear],
                center: .init(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 500
            )
        }
    }

    private var progressIndicator: some View {
        HStack(spacing: 10) {
            ForEach(Step.allCases) { s in
                Capsule()
                    .fill(progressFill(for: s))
                    .frame(width: s == step ? 36 : 8, height: 6)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: step)
            }
        }
    }

    private func progressFill(for s: Step) -> Color {
        if s == step { return .white }
        if s.rawValue < step.rawValue { return .white.opacity(0.5) }
        return .white.opacity(0.15)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: step.icon)
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .glassCircle()
                .padding(.bottom, 6)

            Text(step.title)
                .font(.system(size: 34, weight: .light))
                .tracking(-0.3)

            Text(step.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 580)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .birthdate: birthdateStep
        case .lifespan: lifespanStep
        case .look: lookStep
        case .save: saveStep
        }
    }

    private var birthdateStep: some View {
        VStack {
            Spacer(minLength: 0)
            DatePicker(
                "",
                selection: $settings.birthdate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(.white)
            .environment(\.colorScheme, .dark)
            .scaleEffect(1.7, anchor: .center)
            .frame(width: 320 * 1.7, height: 280 * 1.7)
            .padding(60)
            .glassCard(cornerRadius: 32)
            Spacer(minLength: 0)
        }
    }

    private var lifespanStep: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                slimRow(label: "Total years", value: $settings.totalYears, range: 40...130)
                slimRow(label: "Columns", value: $settings.columns, range: 4...24)
                slimRow(label: "Grow first", value: $settings.fadeInYears, range: 0...30, suffix: " yrs")
                slimRow(label: "Fade last", value: $settings.fadeOutYears, range: 0...30, suffix: " yrs")
            }
            .padding(20)
            .frame(width: 300, alignment: .topLeading)
            .glassCard(cornerRadius: 22)

            preview
        }
    }

    private var lookStep: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                sectionLabel("Background")
                inlineRow(label: "Color") {
                    colorPicker(hex: $settings.backgroundHex)
                }
                imageControls(
                    hasImage: settings.backgroundImage != nil,
                    filename: settings.backgroundImage != nil
                        ? URL(fileURLWithPath: settings.backgroundImagePath).lastPathComponent
                        : nil,
                    onPick: { pickImage(into: .background) },
                    onClear: { settings.clearBackgroundImage() }
                )
                if settings.backgroundImage != nil {
                    Picker("", selection: $settings.backgroundImageMode) {
                        ForEach(BackgroundImageMode.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                slimDivider

                sectionLabel("Dots")
                inlineRow(label: "Color") {
                    colorPicker(hex: $settings.foregroundHex)
                }
                imageControls(
                    hasImage: settings.dotImage != nil,
                    filename: settings.dotImage != nil
                        ? URL(fileURLWithPath: settings.dotImagePath).lastPathComponent
                        : nil,
                    onPick: { pickImage(into: .dots) },
                    onClear: { settings.clearDotImage() }
                )

                slimDivider

                sliderRow(label: "Grid scale", value: $settings.gridScale, range: 0.3...1.0)
                sliderRow(label: "Grid opacity", value: $settings.gridOpacity, range: 0.0...1.0)
            }
            .padding(20)
            .frame(width: 320, alignment: .topLeading)
            .glassCard(cornerRadius: 22)

            preview
        }
    }

    private var saveStep: some View {
        let progress = settings.progress()
        let livedPct = settings.totalYears > 0
            ? Int(Double(progress.yearsLived) / Double(settings.totalYears) * 100)
            : 0
        return VStack(spacing: 22) {
            HStack(spacing: 14) {
                statBlock(value: "\(progress.yearsLived)", caption: "years lived")
                statBlock(value: "\(max(0, settings.totalYears - progress.yearsLived))", caption: "years remaining")
                statBlock(value: "\(livedPct)%", caption: "of \(settings.totalYears)")
            }
            preview
        }
    }

    private var preview: some View {
        LifeGridView(
            progress: settings.progress(),
            backgroundColor: Color(hex: settings.backgroundHex),
            foregroundColor: Color(hex: settings.foregroundHex),
            highlightCurrentYear: settings.highlightCurrentYear,
            backgroundImage: settings.backgroundImage,
            gridScale: settings.gridScale,
            backgroundImageMode: settings.backgroundImageMode,
            dotImage: settings.dotImage,
            gridOpacity: settings.gridOpacity
        )
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var slimDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
            .padding(.vertical, 2)
    }

    private var footer: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                if step != .birthdate {
                    Button("Back") {
                        withAnimation(.smooth(duration: 0.3)) {
                            step = Step(rawValue: step.rawValue - 1) ?? .birthdate
                        }
                    }
                    .buttonStyle(.glass)
                    .controlSize(.extraLarge)
                }
                Spacer()
                if step == .save {
                    Button("Save & set wallpaper") {
                        settings.hasOnboarded = true
                        onFinish()
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.extraLarge)
                    .keyboardShortcut(.defaultAction)
                } else {
                    Button("Continue") {
                        withAnimation(.smooth(duration: 0.3)) {
                            step = Step(rawValue: step.rawValue + 1) ?? .save
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.extraLarge)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
    }

    private func slimRow(label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String = "") -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.65))
            Spacer()
            Text("\(value.wrappedValue)\(suffix)")
                .font(.system(size: 13, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.95))
            Stepper("", value: value, in: range)
                .labelsHidden()
                .controlSize(.small)
        }
        .padding(.vertical, 6)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2)
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.5))
    }

    private func inlineRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            content()
        }
    }

    private func sliderRow(label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 12, weight: .light))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.6))
            }
            Slider(value: value, in: range)
                .tint(.white)
                .controlSize(.small)
        }
    }

    private func colorPicker(hex: Binding<String>) -> some View {
        ColorPicker("", selection: Binding(
            get: { Color(hex: hex.wrappedValue) },
            set: { hex.wrappedValue = $0.toHex() }
        ), supportsOpacity: false)
        .labelsHidden()
    }

    @ViewBuilder
    private func imageControls(
        hasImage: Bool,
        filename: String?,
        onPick: @escaping () -> Void,
        onClear: @escaping () -> Void
    ) -> some View {
        if hasImage {
            HStack(spacing: 8) {
                Text(filename ?? "")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("Replace") { onPick() }
                    .buttonStyle(.glass)
                    .controlSize(.small)
                Button {
                    onClear()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.glass)
                .controlSize(.small)
            }
        } else {
            Button("Choose image…") { onPick() }
                .buttonStyle(.glass)
                .controlSize(.small)
        }
    }

    private func statBlock(value: String, caption: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .light))
                .monospacedDigit()
            Text(caption)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 18)
    }

    private enum ImageSlot { case background, dots }

    private func pickImage(into slot: ImageSlot) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url {
            switch slot {
            case .background: settings.importBackgroundImage(from: url)
            case .dots: settings.importDotImage(from: url)
            }
        }
    }
}
