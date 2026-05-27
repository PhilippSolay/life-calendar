import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
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
        .frame(minWidth: 1000, minHeight: 640)
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
            backgroundImageMode: settings.backgroundImageMode
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.35), radius: 22, y: 10)
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
                    Stepper("Total years: \(settings.totalYears)",
                            value: $settings.totalYears, in: 40...130, step: 1)
                    Stepper("Columns: \(settings.columns)",
                            value: $settings.columns, in: 4...24)
                    let rows = Int(ceil(Double(settings.totalYears) / Double(settings.columns)))
                    Text("Rows (derived): \(rows)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                section("Grid scale on screen") {
                    Slider(value: $settings.gridScale, in: 0.3...1.0)
                        .tint(.white)
                    Text("\(Int(settings.gridScale * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.55))
                }

                section("Fade") {
                    Stepper("Grow first: \(settings.fadeInYears) yrs",
                            value: $settings.fadeInYears, in: 0...30)
                    Stepper("Fade last: \(settings.fadeOutYears) yrs",
                            value: $settings.fadeOutYears, in: 0...30)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smallest first-year scale")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                        Slider(value: $settings.minScale, in: 0.0...0.5).tint(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Faintest last-year opacity")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                        Slider(value: $settings.minOpacity, in: 0.0...0.5).tint(.white)
                    }
                }

                section("Color") {
                    ColorPicker("Background", selection: $backgroundColor, supportsOpacity: false)
                    ColorPicker("Dots", selection: $foregroundColor, supportsOpacity: false)
                    Toggle("Highlight current year", isOn: $settings.highlightCurrentYear)
                }

                section("Background image") {
                    if settings.backgroundImage != nil {
                        Text(URL(fileURLWithPath: settings.backgroundImagePath).lastPathComponent)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        GlassEffectContainer {
                            HStack(spacing: 8) {
                                Button("Replace…") { pickImage() }.buttonStyle(.glass)
                                Button("Remove") { settings.clearBackgroundImage() }.buttonStyle(.glass)
                            }
                        }
                        Picker("Show image", selection: $settings.backgroundImageMode) {
                            ForEach(BackgroundImageMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Button("Choose image…") { pickImage() }.buttonStyle(.glass)
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
