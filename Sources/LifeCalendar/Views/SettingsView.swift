import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var schedule: ScheduleService
    var onApply: () -> Void

    @State private var backgroundColor: Color = .black
    @State private var foregroundColor: Color = .white

    var body: some View {
        ZStack {
            backdrop.ignoresSafeArea()

            HStack(spacing: 20) {
                form
                    .frame(width: 360)
                    .padding(20)
                    .glassCard(cornerRadius: 24)

                preview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(20)
        }
        .frame(minWidth: 1000, minHeight: 680)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onAppear {
            backgroundColor = Color(hex: settings.backgroundHex)
            foregroundColor = Color(hex: settings.foregroundHex)
        }
        .onChange(of: backgroundColor) { _, new in settings.backgroundHex = new.toHex() }
        .onChange(of: foregroundColor) { _, new in settings.foregroundHex = new.toHex() }
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
                colors: [Color.white.opacity(0.06), .clear],
                center: .init(x: 0.2, y: 0.1),
                startRadius: 0,
                endRadius: 600
            )
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
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                section("Birthdate") {
                    DatePicker(
                        "",
                        selection: $settings.birthdate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .tint(.white)
                }

                section("Grid capacity") {
                    slimStepper(label: "Total years", value: $settings.totalYears, range: 40...130)
                    slimStepper(label: "Columns", value: $settings.columns, range: 4...24)
                    let rows = Int(ceil(Double(settings.totalYears) / Double(settings.columns)))
                    Text("\(rows) rows derived")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }

                section("Fade") {
                    slimStepper(label: "Grow first", value: $settings.fadeInYears, range: 0...30, suffix: " yrs")
                    slimStepper(label: "Fade last", value: $settings.fadeOutYears, range: 0...30, suffix: " yrs")
                    sliderRow(label: "Smallest first-year scale", value: $settings.minScale, in: 0.0...0.5)
                    sliderRow(label: "Faintest last-year opacity", value: $settings.minOpacity, in: 0.0...0.5)
                }

                section("Background") {
                    inlineRow(label: "Color") {
                        ColorPicker("", selection: $backgroundColor, supportsOpacity: false)
                            .labelsHidden()
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
                }

                section("Dots") {
                    inlineRow(label: "Color") {
                        ColorPicker("", selection: $foregroundColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                    imageControls(
                        hasImage: settings.dotImage != nil,
                        filename: settings.dotImage != nil
                            ? URL(fileURLWithPath: settings.dotImagePath).lastPathComponent
                            : nil,
                        onPick: { pickImage(into: .dots) },
                        onClear: { settings.clearDotImage() }
                    )
                    Toggle("Highlight current year", isOn: $settings.highlightCurrentYear)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }

                section("Grid") {
                    sliderPercentRow(label: "Scale on screen", value: $settings.gridScale, in: 0.3...1.0)
                    sliderPercentRow(label: "Opacity", value: $settings.gridOpacity, in: 0.0...1.0)
                }

                section("Schedule") {
                    Toggle("Auto-update at login and daily", isOn: scheduleBinding)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                    Text(scheduleStatusText)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    if schedule.requiresApproval {
                        Button("Open Login Items in System Settings…") {
                            schedule.openLoginItems()
                        }
                        .buttonStyle(.glass)
                        .controlSize(.small)
                    }
                }

                Button("Update wallpaper now") {
                    onApply()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption2)
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.5))
            content()
        }
    }

    private func slimStepper(label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String = "") -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text("\(value.wrappedValue)\(suffix)")
                .font(.system(size: 13, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.95))
            Stepper("", value: value, in: range)
                .labelsHidden()
                .controlSize(.small)
        }
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

    private func sliderRow(label: String, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.7))
            Slider(value: value, in: range)
                .tint(.white)
                .controlSize(.small)
        }
    }

    private func sliderPercentRow(label: String, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
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

    private var scheduleBinding: Binding<Bool> {
        Binding(
            get: { schedule.isInstalled },
            set: { newValue in
                if newValue {
                    schedule.install()
                } else {
                    schedule.uninstall()
                }
            }
        )
    }

    private var scheduleStatusText: String {
        switch schedule.status {
        case .enabled: return "Running. Refreshes at login and at 3:00 AM daily."
        case .requiresApproval: return "Waiting for approval in System Settings → Login Items."
        case .notRegistered: return "Not installed. The wallpaper only updates while the app is open."
        case .notFound: return "Schedule plist missing from app bundle."
        @unknown default: return "Unknown status."
        }
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
