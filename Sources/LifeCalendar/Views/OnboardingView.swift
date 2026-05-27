import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct OnboardingView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) private var dismiss
    var onFinish: () -> Void

    @State private var step: Step = .birthdate

    enum Step: Int, CaseIterable, Identifiable {
        case birthdate, lifespan, layout, look, save
        var id: Int { rawValue }

        var title: String {
            switch self {
            case .birthdate: return "When were you born?"
            case .lifespan: return "Your lifespan"
            case .layout: return "Layout"
            case .look: return "Make it yours"
            case .save: return "Ready"
            }
        }

        var subtitle: String {
            switch self {
            case .birthdate: return "Every dot in your calendar is anchored to this date."
            case .lifespan: return "How many years should the grid hold, and how should the edges fade?"
            case .layout: return "Where should the grid sit on your wallpaper?"
            case .look: return "Background, dots, and how much the grid stands out."
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
        .background(WindowConfigurator(showTrafficLights: false))
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
        VStack(spacing: 10) {
            Text(step.title)
                .font(.system(size: 36, weight: .light))
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
        case .layout: layoutStep
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
        VStack(spacing: 28) {
            transparentPreview
                .frame(maxWidth: 540, maxHeight: 320)
                .frame(maxWidth: .infinity)

            HStack(spacing: 16) {
                columnControl(label: "Total years", value: $settings.totalYears, range: 40...130)
                columnControl(label: "Columns", value: $settings.columns, range: 4...24)
                columnControl(label: "Grow first", value: $settings.fadeInYears, range: 0...30, suffix: " yrs")
                columnControl(label: "Fade last", value: $settings.fadeOutYears, range: 0...30, suffix: " yrs")
            }
        }
    }

    private var layoutStep: some View {
        VStack(spacing: 20) {
            preview
                .frame(maxHeight: 360)

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Size")
                    sliderPercentRow(value: $settings.gridScale, range: 0.3...1.0)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .glassCard(cornerRadius: 18)

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Position")
                    anchorMatrix(selected: $settings.gridAnchor)
                }
                .padding(20)
                .glassCard(cornerRadius: 18)

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Side padding")
                    if settings.gridAnchor.isCentered {
                        Text("No effect when centered.")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                    } else {
                        sliderPercentRow(value: $settings.sidePadding, range: 0.0...0.2)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .glassCard(cornerRadius: 18)
            }
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
                Button {
                    settings.importCurrentWallpaper()
                } label: {
                    Label("Use current wallpaper", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.glass)
                .controlSize(.small)
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

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Grid opacity")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("\(Int(settings.gridOpacity * 100))%")
                            .font(.system(size: 12, weight: .light))
                            .monospacedDigit()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Slider(value: $settings.gridOpacity, in: 0.0...1.0)
                        .tint(.white)
                        .controlSize(.small)
                }
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
            gridOpacity: settings.gridOpacity,
            gridAnchor: settings.gridAnchor,
            sidePadding: settings.sidePadding
        )
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var transparentPreview: some View {
        LifeGridView(
            progress: settings.progress(),
            backgroundColor: .clear,
            foregroundColor: .white,
            highlightCurrentYear: settings.highlightCurrentYear,
            backgroundImage: nil,
            gridScale: 1.0,
            backgroundImageMode: .fullScreen,
            dotImage: nil,
            gridOpacity: 1.0,
            gridAnchor: .center,
            sidePadding: 0
        )
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
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

    private func columnControl(label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String = "") -> some View {
        VStack(spacing: 8) {
            Text(label.uppercased())
                .font(.caption2)
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.5))
            Text("\(value.wrappedValue)\(suffix)")
                .font(.system(size: 26, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.white)
            Stepper("", value: value, in: range)
                .labelsHidden()
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 18)
    }

    private func sliderPercentRow(value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Slider(value: value, in: range)
                .tint(.white)
                .controlSize(.small)
            Text("\(Int(value.wrappedValue * 100))%")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    private func anchorMatrix(selected: Binding<GridAnchor>) -> some View {
        let grid: [[GridAnchor]] = [
            [.topLeading, .top, .topTrailing],
            [.leading, .center, .trailing],
            [.bottomLeading, .bottom, .bottomTrailing]
        ]
        return RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            .overlay {
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { col in
                                anchorCell(grid[row][col], selected: selected)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(width: 132, height: 84)
    }

    private func anchorCell(_ anchor: GridAnchor, selected: Binding<GridAnchor>) -> some View {
        Button {
            selected.wrappedValue = anchor
        } label: {
            Circle()
                .fill(selected.wrappedValue == anchor ? .white : .white.opacity(0.22))
                .frame(width: selected.wrappedValue == anchor ? 10 : 7,
                       height: selected.wrappedValue == anchor ? 10 : 7)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected.wrappedValue)
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
