import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct OnboardingView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) private var dismiss
    var onFinish: () -> Void

    @State private var step: Step = .birthdate
    @Namespace private var glassNamespace

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
            case .look: return "Background, colors, and how big the grid sits on your desktop."
            case .save: return "Set your wallpaper now. Everything stays editable from the menu bar."
            }
        }
    }

    var body: some View {
        ZStack {
            backdrop.ignoresSafeArea()

            VStack(spacing: 0) {
                progressIndicator
                    .padding(.top, 36)
                    .padding(.bottom, 26)

                header
                    .padding(.bottom, 28)

                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 44)

                footer
                    .padding(.vertical, 24)
                    .padding(.horizontal, 44)
            }
        }
        .frame(width: 1000, height: 720)
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
        HStack {
            Spacer()
            DatePicker(
                "",
                selection: $settings.birthdate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(.white)
            .frame(maxWidth: 400)
            .padding(24)
            .glassCard(cornerRadius: 24)
            Spacer()
        }
    }

    private var lifespanStep: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 22) {
                fancyStepper(label: "Total years", value: $settings.totalYears, range: 40...130)
                glassDivider
                fancyStepper(label: "Columns", value: $settings.columns, range: 4...24)
                glassDivider
                fancyStepper(label: "Grow first", value: $settings.fadeInYears, range: 0...30, suffix: "yrs")
                glassDivider
                fancyStepper(label: "Fade last", value: $settings.fadeOutYears, range: 0...30, suffix: "yrs")
            }
            .padding(24)
            .frame(width: 340, alignment: .topLeading)
            .glassCard(cornerRadius: 24)

            previewBox
        }
    }

    private var lookStep: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                colorRow(label: "Background", hex: $settings.backgroundHex)
                colorRow(label: "Dots", hex: $settings.foregroundHex)

                glassDivider

                VStack(alignment: .leading, spacing: 8) {
                    fieldLabel("Grid scale on screen")
                    Slider(value: $settings.gridScale, in: 0.3...1.0)
                        .tint(.white)
                    Text("\(Int(settings.gridScale * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.55))
                }

                glassDivider

                fieldLabel("Background image")
                if settings.backgroundImage != nil {
                    Text(URL(fileURLWithPath: settings.backgroundImagePath).lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1).truncationMode(.middle)
                    GlassEffectContainer {
                        HStack(spacing: 8) {
                            Button("Replace…") { pickImage() }
                                .buttonStyle(.glass)
                            Button("Remove") { settings.clearBackgroundImage() }
                                .buttonStyle(.glass)
                        }
                    }
                    Picker("", selection: $settings.backgroundImageMode) {
                        ForEach(BackgroundImageMode.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                } else {
                    Button("Choose image…") { pickImage() }
                        .buttonStyle(.glass)
                }
            }
            .padding(24)
            .frame(width: 340, alignment: .topLeading)
            .glassCard(cornerRadius: 24)

            previewBox
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
            previewBox
        }
    }

    private var previewBox: some View {
        LifeGridView(
            progress: settings.progress(),
            backgroundColor: Color(hex: settings.backgroundHex),
            foregroundColor: Color(hex: settings.foregroundHex),
            highlightCurrentYear: settings.highlightCurrentYear,
            backgroundImage: settings.backgroundImage,
            gridScale: settings.gridScale,
            backgroundImageMode: settings.backgroundImageMode
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var glassDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
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

    private func fancyStepper(label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String = "") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(label)
            HStack {
                Text("\(value.wrappedValue)\(suffix.isEmpty ? "" : " \(suffix)")")
                    .font(.system(size: 24, weight: .light))
                    .monospacedDigit()
                Spacer()
                Stepper("", value: value, in: range)
                    .labelsHidden()
            }
        }
    }

    private func colorRow(label: String, hex: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.78))
            Spacer()
            ColorPicker("", selection: Binding(
                get: { Color(hex: hex.wrappedValue) },
                set: { hex.wrappedValue = $0.toHex() }
            ), supportsOpacity: false)
            .labelsHidden()
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2)
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.5))
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

    private func pickImage() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url {
            settings.importBackgroundImage(from: url)
        }
    }
}
