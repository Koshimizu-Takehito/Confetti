import SwiftUI

// MARK: - ConfettiTriggerButton

/// A stylized button for triggering confetti animation.
///
/// Style is configured via the `.confettiTriggerButtonStyle(_:)` modifier
/// or inherited from the environment.
///
/// ## Example
///
/// ```swift
/// // Default style
/// ConfettiTriggerButton {
///     viewModel.startAnimation(canvasSize: size)
/// }
///
/// // Customized via modifier
/// ConfettiTriggerButton {
///     viewModel.startAnimation(canvasSize: size)
/// }
/// .confettiTriggerButtonStyle(.init(
///     text: "Celebrate!",
///     gradientColors: [.purple, .pink]
/// ))
/// ```
public struct ConfettiTriggerButton: View {
    @Environment(\.confettiTriggerButtonStyle) private var style

    private let action: () -> Void

    /// Creates a trigger button.
    /// - Parameter action: Action to perform when tapped
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(style.text)
                .padding(.horizontal, style.horizontalPadding)
                .padding(.vertical, style.verticalPadding)
                .background {
                    LinearGradient(
                        colors: style.gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(.capsule)
                .shadow(
                    color: style.shadowColor,
                    radius: style.shadowRadius,
                    x: 0,
                    y: style.shadowY
                )
                .contentShape(.capsule)
        }
        .font(.headline.bold())
        .foregroundStyle(style.foregroundColor)
    }
}

// MARK: - Preview

#Preview("Default") {
    ConfettiTriggerButton {}
}

#Preview("Custom Style") {
    ConfettiTriggerButton {}.confettiTriggerButtonStyle(
        .init(
            text: "Celebrate! 🎉",
            gradientColors: [.purple, .pink]
        )
    )
}
