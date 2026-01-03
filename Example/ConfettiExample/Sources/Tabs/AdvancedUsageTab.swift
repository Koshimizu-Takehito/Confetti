import ConfettiUI
import SwiftUI

// MARK: - AdvancedUsageTab

/// A tab displaying advanced customization patterns.
///
/// This view demonstrates advanced ways to customize ConfettiUI:
///
/// - **Custom Colors**: Brand color integration with ConfettiColorSource
/// - **Config Presets Gallery**: Interactive comparison of presets
/// - **Button Styles**: Advanced trigger button customization
/// - **Custom Triggers**: Building complex trigger UI patterns
/// - **Design Tokens**: UI sizing and theming options
/// - **Advanced Playback**: External control with ConfettiCanvas
struct AdvancedUsageTab: View {
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            List {
                Section("Colors & Themes") {
                    NavigationLink {
                        CustomColorsDemo()
                            .navigationTitle("Custom Colors")
                    } label: {
                        DemoListRow(
                            title: "Custom Colors",
                            subtitle: "Brand color integration",
                            systemImage: "paintpalette.fill",
                            colors: [.pink, .purple]
                        )
                    }
                }

                Section("Configuration") {
                    NavigationLink {
                        ConfigPresetsGalleryDemo()
                            .navigationTitle("Config Presets")
                    } label: {
                        DemoListRow(
                            title: "Config Presets Gallery",
                            subtitle: "Interactive preset comparison",
                            systemImage: "slider.horizontal.3",
                            colors: [.orange, .yellow]
                        )
                    }
                }

                Section("Button Customization") {
                    NavigationLink {
                        ButtonStylesDemo()
                            .navigationTitle("Button Styles")
                    } label: {
                        DemoListRow(
                            title: "Button Styles",
                            subtitle: "Trigger button customization",
                            systemImage: "button.horizontal.fill",
                            colors: [.green, .mint]
                        )
                    }
                    NavigationLink {
                        CustomTriggersDemo()
                            .navigationTitle("Custom Triggers")
                    } label: {
                        DemoListRow(
                            title: "Custom Triggers",
                            subtitle: "Icon, FAB, tap anywhere, long press",
                            systemImage: "cursorarrow.click.2",
                            colors: [.blue, .cyan]
                        )
                    }
                }

                Section("Layout & Sizing") {
                    NavigationLink {
                        DesignTokensDemo()
                            .navigationTitle("Design Tokens")
                    } label: {
                        DemoListRow(
                            title: "Design Tokens",
                            subtitle: "Compact, regular, large sizing",
                            systemImage: "textformat.size",
                            colors: [.purple, .indigo]
                        )
                    }
                }

                Section("Playback Control") {
                    NavigationLink {
                        AdvancedPlaybackDemo()
                            .navigationTitle("Advanced Playback")
                    } label: {
                        DemoListRow(
                            title: "Advanced Playback Control",
                            subtitle: "Play, pause, seek with ConfettiCanvas",
                            systemImage: "slider.horizontal.below.square.and.square.filled",
                            colors: [.teal, .mint]
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Advanced")
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
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

// MARK: - AdvancedPlaybackDemo

/// Demonstrates external playback control using ConfettiCanvas directly.
///
/// This pattern is useful when you need full control over the player lifecycle,
/// such as triggering confetti from external events or building custom UI.
private struct AdvancedPlaybackDemo: View {
    @State private var player = ConfettiPlayer()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // Confetti canvas
            ConfettiCanvas(renderStates: player.renderStates)
                .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                    canvasSize = size
                    player.updateCanvasSize(to: size)
                }

            Divider()
            playbackInfo
            Divider()
            controlButtons
        }
        .onDisappear {
            player.stop()
        }
    }

    private var playbackInfo: some View {
        VStack(spacing: 8) {
            Text("Time: \(player.simulation.currentTime, specifier: "%.2f") / \(player.simulation.duration, specifier: "%.1f")s")
                .font(.headline.monospacedDigit())

            ProgressView(value: player.simulation.currentTime, total: player.simulation.duration)
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            ControlButton(icon: "play.fill", label: "Play", color: .green) {
                player.play(canvasSize: canvasSize)
            }
            ControlButton(icon: "pause.fill", label: "Pause", color: .orange) {
                player.pause()
            }
            ControlButton(icon: "playpause.fill", label: "Resume", color: .blue) {
                player.resume()
            }
            ControlButton(icon: "gobackward", label: "Seek 1s", color: .purple) {
                player.seek(to: 1.0)
            }
            ControlButton(icon: "stop.fill", label: "Stop", color: .red) {
                player.stop()
            }
        }
        .padding()
    }
}

// MARK: - ControlButton

private struct ControlButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .accessibilityHidden(true)
                Text(label)
                    .font(.caption2)
            }
            .frame(width: 50, height: 50)
            .foregroundStyle(color)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    AdvancedUsageTab()
}
