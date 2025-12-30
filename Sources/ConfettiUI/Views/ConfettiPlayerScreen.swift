import SwiftUI

// MARK: - ConfettiPlayerScreen

/// A full-featured confetti view with video-player-like controls.
///
/// Provides play/pause/stop controls and a seek slider for
/// interactive confetti playback.
///
/// ## Example
///
/// ```swift
/// struct ContentView: View {
///     @State private var player = ConfettiPlayer()
///
///     var body: some View {
///         ConfettiPlayerScreen(player: player)
///     }
/// }
/// ```
///
/// ## Customization
///
/// Customize the visual appearance using `.confettiDesignTokens(_:)`:
///
/// ```swift
/// ConfettiPlayerScreen(player: player)
///     .confettiDesignTokens(
///         ConfettiDesignTokens(
///             spacing: .init(large: 32),
///             background: .init(gradientColors: [.indigo, .purple])
///         )
///     )
/// ```
public struct ConfettiPlayerScreen: View {
    // MARK: - Properties

    @Bindable private var player: ConfettiPlayer

    // MARK: - Private State

    @State private var canvasSize: CGSize = .zero

    // MARK: - Environment

    @Environment(\.confettiDesignTokens) private var tokens

    // MARK: - Initializer

    /// Creates a confetti player view with the given player.
    /// - Parameter player: The playback controller
    public init(player: ConfettiPlayer) {
        self.player = player
    }

    // MARK: - Body

    public var body: some View {
        ConfettiCanvas(renderStates: player.renderStates)
            .background(content: backgroundGradient)
            .overlay(alignment: .bottom) {
                PlaybackControls(player: player, canvasSize: canvasSize)
                    .padding(.bottom, tokens.spacing.extraLarge)
                    .padding(.horizontal, tokens.spacing.medium)
            }
            .onGeometryChange(for: CGSize.self, of: \.size) { _, newSize in
                canvasSize = newSize
                player.updateCanvasSize(to: newSize)
            }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func backgroundGradient() -> some View {
        LinearGradient(
            colors: tokens.background.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - ConfettiPlayerScreenWithDefaultPlayer

/// A self-contained confetti player view that owns its own `ConfettiPlayer` instance.
///
/// Use this when you don't need external access to the player.
///
/// ## Example
///
/// ```swift
/// ConfettiPlayerScreenWithDefaultPlayer()
/// ```
public struct ConfettiPlayerScreenWithDefaultPlayer: View {
    @State private var player = ConfettiPlayer()

    public init() {}

    public var body: some View {
        ConfettiPlayerScreen(player: player)
    }
}

// MARK: - Previews

#Preview("Default") {
    ConfettiPlayerScreenWithDefaultPlayer()
}

#Preview("Compact") {
    ConfettiPlayerScreenWithDefaultPlayer()
        .confettiDesignTokens(.compact)
}

#Preview("Large") {
    ConfettiPlayerScreenWithDefaultPlayer()
        .confettiDesignTokens(.large)
}
