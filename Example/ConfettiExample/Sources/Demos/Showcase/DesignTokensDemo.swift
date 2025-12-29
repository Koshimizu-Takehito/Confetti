import ConfettiPlayback
import ConfettiUI
import SwiftUI

// MARK: - DesignTokensDemo

/// Demonstrates the design token system for UI customization.
///
/// Shows how to use `.confettiDesignTokens()` modifier to customize
/// the sizing and layout of ConfettiPlayerScreen components.
struct DesignTokensDemo: View {
    @State private var selectedSize: SizeOption = .regular

    var body: some View {
        VStack(spacing: 0) {
            // Size selector
            Picker("Size", selection: $selectedSize) {
                ForEach(SizeOption.allCases) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Size info
            SizeInfoCard(size: selectedSize)
                .padding()

            // Player screen with selected tokens
            ConfettiPlayerScreenWithDefaultPlayer()
                .confettiDesignTokens(selectedSize.tokens)
                .id(selectedSize)
        }
    }
}

// MARK: - SizeOption

private enum SizeOption: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case regular = "Regular"
    case large = "Large"

    var id: String { rawValue }

    var tokens: ConfettiDesignTokens {
        switch self {
        case .compact:
            .compact

        case .regular:
            .regular

        case .large:
            .large
        }
    }

    var description: String {
        switch self {
        case .compact:
            "75% scale. Ideal for widgets or embedded views."

        case .regular:
            "100% scale. Standard sizing for most use cases."

        case .large:
            "125% scale. Better touch targets and accessibility."
        }
    }

    var specs: [(String, String)] {
        let tokens = tokens
        return [
            ("Button", "\(Int(tokens.button.primarySize))pt"),
            ("Spacing", "\(Int(tokens.spacing.medium))pt"),
            ("Thumb", "\(Int(tokens.slider.thumbDiameter))pt"),
            ("Font", "\(Int(tokens.font.timeLabel))pt"),
        ]
    }
}

// MARK: - SizeInfoCard

private struct SizeInfoCard: View {
    let size: SizeOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(size.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(size.specs, id: \.0) { label, value in
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
    DesignTokensDemo()
}
