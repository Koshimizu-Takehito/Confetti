import SwiftUI

// MARK: - ConfettiTriggerButtonStyle

/// Style configuration for `ConfettiTriggerButton`.
///
/// Apply via the `.confettiTriggerButtonStyle(_:)` modifier.
///
/// ## Example
///
/// ```swift
/// ConfettiTriggerButton {
///     startAnimation()
/// }
/// .confettiTriggerButtonStyle(.init(
///     text: "Celebrate!",
///     gradientColors: [.purple, .pink]
/// ))
/// ```
public struct ConfettiTriggerButtonStyle: Sendable {
    /// Button text
    public var text: String

    /// Gradient colors (leading to trailing)
    public var gradientColors: [Color]

    /// Text color
    public var foregroundColor: Color

    /// Horizontal padding
    public var horizontalPadding: CGFloat

    /// Vertical padding
    public var verticalPadding: CGFloat

    /// Shadow color
    public var shadowColor: Color

    /// Shadow radius
    public var shadowRadius: CGFloat

    /// Shadow Y offset
    public var shadowY: CGFloat

    /// Default gradient colors (green to mint)
    public static let defaultGradientColors: [Color] = [.green, .mint]

    /// Creates a style with the specified parameters.
    public init(
        text: String = "Confetti!",
        gradientColors: [Color] = Self.defaultGradientColors,
        foregroundColor: Color = .white,
        horizontalPadding: CGFloat = 40,
        verticalPadding: CGFloat = 16,
        shadowColor: Color = .black.opacity(0.2),
        shadowRadius: CGFloat = 10,
        shadowY: CGFloat = 5
    ) {
        self.text = text
        self.gradientColors = gradientColors
        self.foregroundColor = foregroundColor
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
    }

    /// Default style
    public static let `default` = Self()
}
