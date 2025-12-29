import ConfettiUI
import SwiftUI

// MARK: - ButtonStylesDemo

/// Demonstrates various trigger button style customizations.
///
/// Shows how to use `.confettiTriggerButtonStyle()` modifier
/// to customize the appearance of the built-in trigger button.
struct ButtonStylesDemo: View {
    @State private var selectedStyle: ButtonStyleOption = .default

    var body: some View {
        VStack(spacing: 0) {
            // Style selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ButtonStyleOption.allCases) { style in
                        StyleButton(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectedStyle = style
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            // Code preview
            CodePreviewCard(style: selectedStyle)
                .padding()

            // Confetti view with selected style
            ConfettiScreen()
                .confettiTriggerButtonStyle(selectedStyle.buttonStyle)
                .id(selectedStyle)
        }
    }
}

// MARK: - ButtonStyleOption

private enum ButtonStyleOption: String, CaseIterable, Identifiable {
    case `default` = "Default"
    case party = "Party"
    case ocean = "Ocean"
    case sunset = "Sunset"
    case minimal = "Minimal"

    var id: String { rawValue }

    var buttonStyle: ConfettiTriggerButtonStyle {
        switch self {
        case .default:
            .default

        case .party:
            ConfettiTriggerButtonStyle(
                text: "Party! 🎉",
                gradientColors: [.purple, .pink]
            )

        case .ocean:
            ConfettiTriggerButtonStyle(
                text: "Splash! 🌊",
                gradientColors: [.cyan, .blue]
            )

        case .sunset:
            ConfettiTriggerButtonStyle(
                text: "Celebrate! ✨",
                gradientColors: [.orange, .red]
            )

        case .minimal:
            ConfettiTriggerButtonStyle(
                text: "Go",
                gradientColors: [.gray, .black],
                horizontalPadding: 60,
                verticalPadding: 12
            )
        }
    }

    var previewColors: [Color] {
        buttonStyle.gradientColors
    }

    var codeSnippet: String {
        switch self {
        case .default:
            """
            ConfettiScreen()
            """

        case .party:
            """
            ConfettiScreen()
                .confettiTriggerButtonStyle(.init(
                    text: "Party! 🎉",
                    gradientColors: [.purple, .pink]
                ))
            """

        case .ocean:
            """
            ConfettiScreen()
                .confettiTriggerButtonStyle(.init(
                    text: "Splash! 🌊",
                    gradientColors: [.cyan, .blue]
                ))
            """

        case .sunset:
            """
            ConfettiScreen()
                .confettiTriggerButtonStyle(.init(
                    text: "Celebrate! ✨",
                    gradientColors: [.orange, .red]
                ))
            """

        case .minimal:
            """
            ConfettiScreen()
                .confettiTriggerButtonStyle(.init(
                    text: "Go",
                    gradientColors: [.gray, .black],
                    horizontalPadding: 60,
                    verticalPadding: 12
                ))
            """
        }
    }
}

// MARK: - StyleButton

private struct StyleButton: View {
    let style: ButtonStyleOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: style.previewColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Text(style.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(width: 70, height: 65)
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

// MARK: - CodePreviewCard

private struct CodePreviewCard: View {
    let style: ButtonStyleOption

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("Code")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(style.codeSnippet)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

#Preview {
    ButtonStylesDemo()
}
