import ConfettiPlayback
import ConfettiUI
import SwiftUI

// MARK: - CustomColorsDemo

/// Demonstrates how to use custom brand colors with ConfettiPlayer.
///
/// This demo shows how to implement `ConfettiColorSource` protocol
/// to create a custom color palette for your confetti animation.
struct CustomColorsDemo: View {
    @State private var selectedPalette: ColorPalette = .brand

    var body: some View {
        VStack(spacing: 0) {
            // Color palette picker
            Picker("Color Palette", selection: $selectedPalette) {
                ForEach(ColorPalette.allCases) { palette in
                    Text(palette.rawValue).tag(palette)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Confetti view with custom trigger
            ConfettiScreen(
                ConfettiPlayer(colorSource: selectedPalette.colorSource)
            ) { _, play in
                DemoTriggerButton(colors: selectedPalette.previewColors, action: play)
            }
            .id(selectedPalette) // Recreate when palette changes
        }
    }
}

// MARK: - ColorPalette

private enum ColorPalette: String, CaseIterable, Identifiable {
    case brand = "Brand"
    case pastel = "Pastel"
    case neon = "Neon"
    case monochrome = "Mono"

    var id: String { rawValue }

    var colorSource: any ConfettiColorSource {
        switch self {
        case .brand:
            BrandColorSource()

        case .pastel:
            PastelColorSource()

        case .neon:
            NeonColorSource()

        case .monochrome:
            MonochromeColorSource()
        }
    }

    var previewColors: [Color] {
        switch self {
        case .brand:
            [.blue, .purple]

        case .pastel:
            [Color(red: 1.0, green: 0.8, blue: 0.9), Color(red: 0.8, green: 0.9, blue: 1.0)]

        case .neon:
            [Color(red: 0.0, green: 1.0, blue: 0.5), Color(red: 1.0, green: 0.0, blue: 0.5)]

        case .monochrome:
            [.gray, .black]
        }
    }
}

// MARK: - BrandColorSource

/// Example brand color source using company colors.
private struct BrandColorSource: ConfettiColorSource {
    private let colors: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1), // Brand Blue
        CGColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1), // Brand Purple
        CGColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1), // Brand Pink
        CGColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1), // Brand Teal
    ]

    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &rng) ?? colors[0]
    }
}

// MARK: - PastelColorSource

/// Soft pastel colors for a gentle, elegant effect.
private struct PastelColorSource: ConfettiColorSource {
    private let colors: [CGColor] = [
        CGColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1), // Pink
        CGColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1), // Blue
        CGColor(red: 0.9, green: 1.0, blue: 0.8, alpha: 1), // Green
        CGColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1), // Yellow
        CGColor(red: 0.9, green: 0.85, blue: 1.0, alpha: 1), // Lavender
    ]

    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &rng) ?? colors[0]
    }
}

// MARK: - NeonColorSource

/// Vibrant neon colors for a bold, energetic effect.
private struct NeonColorSource: ConfettiColorSource {
    private let colors: [CGColor] = [
        CGColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1), // Neon Green
        CGColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1), // Neon Pink
        CGColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1), // Neon Cyan
        CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1), // Neon Yellow
        CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1), // Neon Orange
    ]

    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &rng) ?? colors[0]
    }
}

// MARK: - MonochromeColorSource

/// Grayscale colors for a sophisticated, minimal effect.
private struct MonochromeColorSource: ConfettiColorSource {
    private let colors: [CGColor] = [
        CGColor(gray: 0.2, alpha: 1),
        CGColor(gray: 0.4, alpha: 1),
        CGColor(gray: 0.6, alpha: 1),
        CGColor(gray: 0.8, alpha: 1),
        CGColor(gray: 1.0, alpha: 1),
    ]

    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &rng) ?? colors[0]
    }
}

#Preview {
    CustomColorsDemo()
}
