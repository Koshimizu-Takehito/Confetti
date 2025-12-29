import SwiftUI

// MARK: - ConfettiDesignTokens

/// Design tokens for the Confetti Player UI components.
///
/// Provides a centralized, semantic naming system for spacing, sizing,
/// colors, and other visual properties used across the player views.
///
/// ## Presets
///
/// Use built-in presets for common scenarios:
///
/// ```swift
/// // Standard sizing (default)
/// ConfettiPlayerScreen(player: player)
///     .confettiDesignTokens(.default)
///
/// // Compact sizing for small screens or widgets
/// ConfettiPlayerScreen(player: player)
///     .confettiDesignTokens(.compact)
///
/// // Large sizing for accessibility
/// ConfettiPlayerScreen(player: player)
///     .confettiDesignTokens(.large)
/// ```
///
/// ## Custom Tokens
///
/// Create custom tokens by modifying specific values:
///
/// ```swift
/// ConfettiPlayerScreen(player: player)
///     .confettiDesignTokens(
///         ConfettiDesignTokens(
///             spacing: .init(medium: 20),
///             button: .init(primarySize: 64)
///         )
///     )
/// ```
public struct ConfettiDesignTokens: Sendable {
    // MARK: - Nested Types

    /// Semantic spacing values for consistent layout.
    public struct Spacing: Sendable {
        /// Extra small spacing (8pt) - tight gaps
        public var extraSmall: CGFloat

        /// Small spacing (12pt) - compact elements
        public var small: CGFloat

        /// Medium spacing (16pt) - standard padding
        public var medium: CGFloat

        /// Large spacing (24pt) - section gaps
        public var large: CGFloat

        /// Extra large spacing (32pt) - major sections
        public var extraLarge: CGFloat

        /// Creates spacing tokens with specified values.
        public init(
            extraSmall: CGFloat = 8,
            small: CGFloat = 12,
            medium: CGFloat = 16,
            large: CGFloat = 24,
            extraLarge: CGFloat = 32
        ) {
            self.extraSmall = extraSmall
            self.small = small
            self.medium = medium
            self.large = large
            self.extraLarge = extraLarge
        }
    }

    /// Corner radius values for rounded elements.
    public struct CornerRadius: Sendable {
        /// Large corner radius (16pt) - cards, panels
        public var large: CGFloat

        /// Creates corner radius tokens with specified values.
        public init(large: CGFloat = 16) {
            self.large = large
        }
    }

    /// Button sizing tokens.
    public struct Button: Sendable {
        /// Primary button diameter (56pt)
        public var primarySize: CGFloat

        /// Secondary button diameter (44pt)
        public var secondarySize: CGFloat

        /// Primary button icon size (28pt)
        public var primaryIconSize: CGFloat

        /// Secondary button icon size (20pt)
        public var secondaryIconSize: CGFloat

        /// Creates button tokens with specified values.
        public init(
            primarySize: CGFloat = 56,
            secondarySize: CGFloat = 44,
            primaryIconSize: CGFloat = 28,
            secondaryIconSize: CGFloat = 20
        ) {
            self.primarySize = primarySize
            self.secondarySize = secondarySize
            self.primaryIconSize = primaryIconSize
            self.secondaryIconSize = secondaryIconSize
        }
    }

    /// Slider component sizing tokens.
    public struct Slider: Sendable {
        /// Thumb circle diameter (18pt)
        public var thumbDiameter: CGFloat

        /// Track height (6pt)
        public var trackHeight: CGFloat

        /// Time label fixed width (40pt)
        public var timeLabelWidth: CGFloat

        /// Thumb circle radius (computed from diameter)
        public var thumbRadius: CGFloat { thumbDiameter / 2 }

        /// Creates slider tokens with specified values.
        public init(
            thumbDiameter: CGFloat = 18,
            trackHeight: CGFloat = 6,
            timeLabelWidth: CGFloat = 40
        ) {
            self.thumbDiameter = thumbDiameter
            self.trackHeight = trackHeight
            self.timeLabelWidth = timeLabelWidth
        }
    }

    /// Opacity values for visual states and effects.
    public struct Opacity: Sendable {
        /// Disabled state opacity (0.3)
        public var disabled: CGFloat

        /// Disabled background opacity (0.5)
        public var disabledBackground: CGFloat

        /// Secondary button background (0.1)
        public var secondaryBackground: CGFloat

        /// Track background (0.2)
        public var trackBackground: CGFloat

        /// Shadow opacity light (0.2)
        public var shadowLight: CGFloat

        /// Shadow opacity medium (0.3)
        public var shadowMedium: CGFloat

        /// Creates opacity tokens with specified values.
        public init(
            disabled: CGFloat = 0.3,
            disabledBackground: CGFloat = 0.5,
            secondaryBackground: CGFloat = 0.1,
            trackBackground: CGFloat = 0.2,
            shadowLight: CGFloat = 0.2,
            shadowMedium: CGFloat = 0.3
        ) {
            self.disabled = disabled
            self.disabledBackground = disabledBackground
            self.secondaryBackground = secondaryBackground
            self.trackBackground = trackBackground
            self.shadowLight = shadowLight
            self.shadowMedium = shadowMedium
        }
    }

    /// Shadow radius values.
    public struct Shadow: Sendable {
        /// Controls panel shadow radius (10pt)
        public var controlsRadius: CGFloat

        /// Thumb shadow radius (2pt)
        public var thumbRadius: CGFloat

        /// Creates shadow tokens with specified values.
        public init(
            controlsRadius: CGFloat = 10,
            thumbRadius: CGFloat = 2
        ) {
            self.controlsRadius = controlsRadius
            self.thumbRadius = thumbRadius
        }
    }

    /// Font sizing tokens.
    public struct Font: Sendable {
        /// Time label font size (12pt)
        public var timeLabel: CGFloat

        /// Creates font tokens with specified values.
        public init(timeLabel: CGFloat = 12) {
            self.timeLabel = timeLabel
        }
    }

    /// Background gradient colors for the player view.
    public struct Background: Sendable {
        /// Gradient color stops for dark theme
        public var gradientColors: [Color]

        /// Creates background tokens with specified values.
        public init(gradientColors: [Color] = [.purple, .blue]) {
            self.gradientColors = gradientColors
        }
    }

    // MARK: - Properties

    /// Spacing tokens
    public var spacing: Spacing

    /// Corner radius tokens
    public var cornerRadius: CornerRadius

    /// Button tokens
    public var button: Button

    /// Slider tokens
    public var slider: Slider

    /// Opacity tokens
    public var opacity: Opacity

    /// Shadow tokens
    public var shadow: Shadow

    /// Font tokens
    public var font: Font

    /// Background tokens
    public var background: Background

    // MARK: - Initializer

    /// Creates design tokens with the specified values.
    ///
    /// All parameters have sensible defaults matching the standard Confetti theme.
    public init(
        spacing: Spacing = .init(),
        cornerRadius: CornerRadius = .init(),
        button: Button = .init(),
        slider: Slider = .init(),
        opacity: Opacity = .init(),
        shadow: Shadow = .init(),
        font: Font = .init(),
        background: Background = .init()
    ) {
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.button = button
        self.slider = slider
        self.opacity = opacity
        self.shadow = shadow
        self.font = font
        self.background = background
    }
}

// MARK: - Presets

public extension ConfettiDesignTokens {
    /// Compact design tokens for smaller screens or embedded widgets.
    ///
    /// All sizes are scaled down to approximately 75% of the regular size.
    /// Use this when space is limited or when embedding the player in a smaller container.
    ///
    /// ```swift
    /// ConfettiPlayerScreen(player: player)
    ///     .confettiDesignTokens(.compact)
    /// ```
    static let compact = ConfettiDesignTokens(
        spacing: Spacing(
            extraSmall: 6,
            small: 8,
            medium: 12,
            large: 16,
            extraLarge: 24
        ),
        cornerRadius: CornerRadius(large: 12),
        button: Button(
            primarySize: 44,
            secondarySize: 36,
            primaryIconSize: 22,
            secondaryIconSize: 16
        ),
        slider: Slider(
            thumbDiameter: 14,
            trackHeight: 4,
            timeLabelWidth: 36
        ),
        shadow: Shadow(
            controlsRadius: 8,
            thumbRadius: 1
        ),
        font: Font(timeLabel: 10)
    )

    /// Regular design tokens with standard sizing.
    ///
    /// The baseline size (100%) suitable for most use cases.
    ///
    /// ```swift
    /// ConfettiPlayerScreen(player: player)
    ///     .confettiDesignTokens(.regular)
    /// ```
    static let regular = ConfettiDesignTokens()

    /// Large design tokens for accessibility or large displays.
    ///
    /// All sizes are scaled up to approximately 125% of the regular size.
    /// Use this to improve touch targets and readability for users who need larger UI elements.
    ///
    /// ```swift
    /// ConfettiPlayerScreen(player: player)
    ///     .confettiDesignTokens(.large)
    /// ```
    static let large = ConfettiDesignTokens(
        spacing: Spacing(
            extraSmall: 10,
            small: 16,
            medium: 20,
            large: 32,
            extraLarge: 40
        ),
        cornerRadius: CornerRadius(large: 20),
        button: Button(
            primarySize: 72,
            secondarySize: 56,
            primaryIconSize: 36,
            secondaryIconSize: 26
        ),
        slider: Slider(
            thumbDiameter: 24,
            trackHeight: 8,
            timeLabelWidth: 48
        ),
        shadow: Shadow(
            controlsRadius: 12,
            thumbRadius: 3
        ),
        font: Font(timeLabel: 14)
    )

    /// The default design tokens.
    ///
    /// Currently set to ``regular``. Use this when you don't need a specific size variant.
    static let `default` = regular
}
