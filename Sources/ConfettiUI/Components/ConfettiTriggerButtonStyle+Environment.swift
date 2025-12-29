import SwiftUI

// MARK: - Environment

public extension EnvironmentValues {
    /// The style for `ConfettiTriggerButton`.
    @Entry var confettiTriggerButtonStyle = ConfettiTriggerButtonStyle.default
}

// MARK: - View Modifier

public extension View {
    /// Sets the style for `ConfettiTriggerButton` in this view hierarchy.
    ///
    /// ## Example
    ///
    /// ```swift
    /// ConfettiTriggerButton {
    ///     startAnimation()
    /// }
    /// .confettiTriggerButtonStyle(.init(
    ///     text: "Party! 🎉",
    ///     gradientColors: [.purple, .pink]
    /// ))
    /// ```
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A view with the style applied
    func confettiTriggerButtonStyle(_ style: ConfettiTriggerButtonStyle) -> some View {
        environment(\.confettiTriggerButtonStyle, style)
    }
}
