import ConfettiPlayback
import ConfettiUI
import SwiftUI

// MARK: - ConfigPresetsGalleryDemo

/// Demonstrates the built-in configuration presets.
///
/// This demo shows a side-by-side comparison of all available presets:
/// - `.celebration` - Balanced and festive (default)
/// - `.subtle` - Gentle and elegant
/// - `.explosion` - Maximum impact
/// - `.snowfall` - Gentle falling effect
struct ConfigPresetsGalleryDemo: View {
    @State private var selectedPreset: ConfigPreset = .celebration
    @State private var player: ConfettiPlayer?

    var body: some View {
        VStack(spacing: 0) {
            // Preset selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ConfigPreset.allCases) { preset in
                        PresetButton(
                            preset: preset,
                            isSelected: selectedPreset == preset
                        ) {
                            selectedPreset = preset
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            // Preset info
            PresetInfoCard(preset: selectedPreset)
                .padding()

            // Confetti view
            if let player {
                ConfettiScreen(player)
                    .id(selectedPreset)
            }
        }
        .onAppear {
            updatePlayer()
        }
        .onChange(of: selectedPreset) { _, _ in
            updatePlayer()
        }
    }

    private func updatePlayer() {
        player?.stop()
        player = selectedPreset.createPlayer()
    }
}

// MARK: - ConfigPreset

private enum ConfigPreset: String, CaseIterable, Identifiable {
    case celebration = "Celebration"
    case subtle = "Subtle"
    case explosion = "Explosion"
    case snowfall = "Snowfall"

    var id: String { rawValue }

    func createPlayer() -> ConfettiPlayer {
        switch self {
        case .celebration:
            ConfettiPlayer(configuration: .celebration)

        case .subtle:
            ConfettiPlayer(configuration: .subtle)

        case .explosion:
            ConfettiPlayer(configuration: .explosion)

        case .snowfall:
            ConfettiPlayer(configuration: .snowfall)
        }
    }

    var icon: String {
        switch self {
        case .celebration:
            "party.popper.fill"

        case .subtle:
            "sparkle"

        case .explosion:
            "flame.fill"

        case .snowfall:
            "snowflake"
        }
    }

    var colors: [Color] {
        switch self {
        case .celebration:
            [.pink, .purple]

        case .subtle:
            [.mint, .teal]

        case .explosion:
            [.orange, .red]

        case .snowfall:
            [.cyan, .blue]
        }
    }

    var description: String {
        switch self {
        case .celebration:
            "Balanced and festive. Good for general celebrations."

        case .subtle:
            "Gentle and elegant. Ideal for understated moments."

        case .explosion:
            "Maximum impact. Great for major achievements."

        case .snowfall:
            "Gentle falling effect. Creates calm atmosphere."
        }
    }

    /// Pre-defined specs for each preset (hardcoded to avoid accessing ConfettiCore internals)
    var specs: [(String, String)] {
        switch self {
        case .celebration:
            [
                ("Particles", "150"),
                ("Duration", "3.0s"),
                ("Gravity", "2500"),
                ("Speed", "1800–4000"),
            ]

        case .subtle:
            [
                ("Particles", "50"),
                ("Duration", "4.0s"),
                ("Gravity", "1200"),
                ("Speed", "800–1500"),
            ]

        case .explosion:
            [
                ("Particles", "300"),
                ("Duration", "4.0s"),
                ("Gravity", "3000"),
                ("Speed", "2500–5000"),
            ]

        case .snowfall:
            [
                ("Particles", "80"),
                ("Duration", "6.0s"),
                ("Gravity", "400"),
                ("Speed", "100–300"),
            ]
        }
    }
}

// MARK: - PresetButton

private struct PresetButton: View {
    let preset: ConfigPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .accessibilityHidden(true)
                    .foregroundStyle(
                        LinearGradient(
                            colors: preset.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(preset.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PresetInfoCard

private struct PresetInfoCard: View {
    let preset: ConfigPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(preset.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(preset.specs, id: \.0) { label, value in
                    VStack(spacing: 4) {
                        Text(value)
                            .font(.headline.monospacedDigit())
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

#Preview {
    ConfigPresetsGalleryDemo()
}
