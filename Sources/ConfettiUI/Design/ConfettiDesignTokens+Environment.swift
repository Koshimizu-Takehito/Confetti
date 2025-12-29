import SwiftUI

// MARK: - Environment

public extension EnvironmentValues {
    /// The design tokens for Confetti UI components.
    ///
    /// Use this to customize spacing, sizing, colors, and other visual properties
    /// throughout the Confetti view hierarchy.
    ///
    /// ## Example
    ///
    /// ```swift
    /// ConfettiPlayerScreen(player: player)
    ///     .confettiDesignTokens(
    ///         ConfettiDesignTokens(
    ///             spacing: .init(medium: 20),
    ///             background: .init(gradientColors: [.blue, .purple])
    ///         )
    ///     )
    /// ```
    @Entry var confettiDesignTokens = ConfettiDesignTokens.default
}

// MARK: - View Modifier

public extension View {
    /// Sets the design tokens for Confetti UI components in this view hierarchy.
    ///
    /// Use this modifier to customize the visual appearance of Confetti components
    /// including spacing, button sizes, slider dimensions, and colors.
    ///
    /// ## Example
    ///
    /// ```swift
    /// ConfettiPlayerScreen(player: player)
    ///     .confettiDesignTokens(
    ///         ConfettiDesignTokens(
    ///             spacing: .init(large: 32),
    ///             button: .init(primarySize: 64),
    ///             background: .init(gradientColors: [.indigo, .purple])
    ///         )
    ///     )
    /// ```
    ///
    /// - Parameter tokens: The design tokens to apply
    /// - Returns: A view with the design tokens applied
    func confettiDesignTokens(_ tokens: ConfettiDesignTokens) -> some View {
        environment(\.confettiDesignTokens, tokens)
    }
}
