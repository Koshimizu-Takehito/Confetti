import ConfettiUI
import SwiftUI

// MARK: - BasicUsageTab

/// A tab displaying basic usage patterns from the README.
///
/// This view demonstrates the fundamental ways to use ConfettiUI:
///
/// - **Minimal**: Single-line ConfettiScreen usage
/// - **Full Controls**: ConfettiPlayerScreen with playback controls
/// - **Custom Trigger**: Building your own trigger button
/// - **Button Style**: Customizing the default trigger button
/// - **Presets**: Using configuration presets
/// - **Custom Config**: Fine-tune animation parameters
struct BasicUsageTab: View {
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            List {
                Section("Getting Started") {
                    NavigationLink {
                        MinimalDemo()
                            .navigationTitle("Minimal")
                    } label: {
                        DemoListRow(
                            title: "Minimal Usage",
                            subtitle: "Single-line ConfettiScreen",
                            systemImage: "sparkle",
                            colors: [.pink, .purple]
                        )
                    }
                    NavigationLink {
                        ConfettiPlayerScreenWithDefaultPlayer()
                            .navigationTitle("Full Controls")
                    } label: {
                        DemoListRow(
                            title: "Full Playback Controls",
                            subtitle: "Play, pause, seek, and more",
                            systemImage: "play.circle.fill",
                            colors: [.green, .mint]
                        )
                    }
                }

                Section("Customization") {
                    NavigationLink {
                        CustomTriggerDemo()
                            .navigationTitle("Custom Trigger")
                    } label: {
                        DemoListRow(
                            title: "Custom Trigger Button",
                            subtitle: "Build your own trigger UI",
                            systemImage: "hand.tap.fill",
                            colors: [.orange, .yellow]
                        )
                    }
                    NavigationLink {
                        ButtonStyleDemo()
                            .navigationTitle("Button Style")
                    } label: {
                        DemoListRow(
                            title: "Button Style Customization",
                            subtitle: "Customize the default button",
                            systemImage: "paintbrush.fill",
                            colors: [.purple, .pink]
                        )
                    }
                    NavigationLink {
                        PresetsDemo()
                            .navigationTitle("Presets")
                    } label: {
                        DemoListRow(
                            title: "Configuration Presets",
                            subtitle: "celebration, subtle, explosion, snowfall",
                            systemImage: "square.stack.3d.up",
                            colors: [.blue, .cyan]
                        )
                    }
                    NavigationLink {
                        CustomConfigDemo()
                            .navigationTitle("Custom Config")
                    } label: {
                        DemoListRow(
                            title: "Custom Configuration",
                            subtitle: "Fine-tune animation parameters",
                            systemImage: "gearshape.2.fill",
                            colors: [.indigo, .purple]
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Basic")
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        // swiftlint:enable closure_body_length
    }
}

// MARK: - MinimalDemo

/// Demonstrates the simplest usage: just ConfettiScreen()
private struct MinimalDemo: View {
    var body: some View {
        ConfettiScreen()
    }
}

// MARK: - CustomTriggerDemo

/// Demonstrates custom trigger button usage
private struct CustomTriggerDemo: View {
    var body: some View {
        ConfettiScreen { _, play in
            Button("Celebrate! 🎉") {
                play()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - ButtonStyleDemo

/// Demonstrates button style customization
private struct ButtonStyleDemo: View {
    var body: some View {
        ConfettiScreen()
            .confettiTriggerButtonStyle(.init(
                text: "Party! 🎊",
                gradientColors: [.purple, .pink]
            ))
    }
}

// MARK: - PresetsDemo

/// Demonstrates configuration presets
private struct PresetsDemo: View {
    @State private var selectedPreset: Preset = .celebration

    var body: some View {
        VStack(spacing: 0) {
            Picker("Preset", selection: $selectedPreset) {
                ForEach(Preset.allCases) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            ConfettiScreen(ConfettiPlayer(configuration: selectedPreset.config))
                .id(selectedPreset)
        }
    }

    private enum Preset: String, CaseIterable, Identifiable {
        case celebration = "Celebration"
        case subtle = "Subtle"
        case explosion = "Explosion"
        case snowfall = "Snowfall"

        var id: String { rawValue }

        var config: ConfettiConfig {
            switch self {
            case .celebration: .celebration
            case .subtle: .subtle
            case .explosion: .explosion
            case .snowfall: .snowfall
            }
        }
    }
}

// MARK: - CustomConfigDemo

/// Demonstrates custom configuration with adjustable parameters
private struct CustomConfigDemo: View {
    @State private var particleCount: Double = 150
    @State private var duration: Double = 3.0
    @State private var gravity: Double = 2500
    @State private var player: ConfettiPlayer?

    var body: some View {
        VStack(spacing: 0) {
            // Configuration controls
            Form {
                Section("Lifecycle") {
                    SliderRow(label: "Particles", value: $particleCount, range: 50 ... 300, step: 10)
                    SliderRow(label: "Duration", value: $duration, range: 1 ... 6, step: 0.5, unit: "s")
                }
                Section("Physics") {
                    SliderRow(label: "Gravity", value: $gravity, range: 500 ... 4000, step: 100)
                }
            }
            .frame(height: 280)

            Divider()

            // Confetti view
            if let player {
                ConfettiScreen(player)
                    .id(configId)
            }
        }
        .onAppear { updatePlayer() }
        .onChange(of: configId) { _, _ in updatePlayer() }
    }

    private var configId: String {
        "\(Int(particleCount))-\(duration)-\(Int(gravity))"
    }

    private func updatePlayer() {
        var config = ConfettiConfig()
        config.lifecycle.particleCount = Int(particleCount)
        config.lifecycle.duration = duration
        config.physics.gravity = gravity
        player?.stop()
        player = ConfettiPlayer(configuration: config)
    }
}

// MARK: - SliderRow

private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var unit: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value, specifier: step >= 1 ? "%.0f" : "%.1f")\(unit)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

#Preview {
    BasicUsageTab()
}
