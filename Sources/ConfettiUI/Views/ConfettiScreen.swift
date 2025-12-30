import SwiftUI

// MARK: - ConfettiScreen

/// A view that displays confetti animation with customizable trigger.
///
/// `ConfettiScreen` combines `ConfettiCanvas` with a Player and optional trigger UI.
/// The trigger can be customized or omitted entirely for external control.
///
/// ## Usage
///
/// ### Default (with built-in trigger button)
/// ```swift
/// ConfettiScreen()
/// ```
///
/// ### Custom Player
/// ```swift
/// var config = ConfettiConfig()
/// config.lifecycle.particleCount = 200
/// let player = ConfettiPlayer(configuration: config)
/// ConfettiScreen(player)
/// ```
///
/// ### Custom Trigger Button Style (via Environment)
/// ```swift
/// ConfettiScreen()
///     .confettiTriggerButtonStyle(.init(
///         text: "Celebrate!",
///         gradientColors: [.purple, .pink]
///     ))
/// ```
///
/// ### Custom Trigger
/// ```swift
/// ConfettiScreen { canvasSize, play in
///     Button("Celebrate!") {
///         play()
///     }
/// }
/// ```
///
/// ### External Control (use ConfettiCanvas directly)
/// ```swift
/// @State var player = ConfettiPlayer()
/// @State var canvasSize: CGSize = .zero
///
/// ConfettiCanvas(renderStates: player.renderStates)
///     .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
///         canvasSize = size
///         player.updateCanvasSize(to: size)
///     }
///     .onTapGesture {
///         player.play(canvasSize: canvasSize)
///     }
/// ```
public struct ConfettiScreen<Trigger: View>: View {
    // MARK: - Properties

    @State private var player: ConfettiPlayer
    private let triggerBuilder: (_ canvasSize: CGSize, _ play: @escaping () -> Void) -> Trigger
    private let triggerAlignment: Alignment
    private let triggerPadding: EdgeInsets

    // MARK: - Initializer

    /// Creates a confetti view with custom trigger.
    /// - Parameters:
    ///   - player: The player that controls the playback
    ///   - triggerAlignment: Alignment of the trigger overlay (default: `.bottom`)
    ///   - triggerPadding: Padding around the trigger (default: bottom 50)
    ///   - trigger: A view builder that receives canvas size and play action
    public init(
        _ player: ConfettiPlayer,
        triggerAlignment: Alignment = .bottom,
        triggerPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0),
        @ViewBuilder trigger: @escaping (_ canvasSize: CGSize, _ play: @escaping () -> Void) -> Trigger
    ) {
        _player = State(initialValue: player)
        self.triggerAlignment = triggerAlignment
        self.triggerPadding = triggerPadding
        self.triggerBuilder = trigger
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ConfettiCanvas(renderStates: player.renderStates)
                .overlay(alignment: triggerAlignment) {
                    triggerBuilder(geometry.size) {
                        player.play(canvasSize: geometry.size)
                    }
                    .padding(triggerPadding)
                }
                .onChange(of: geometry.size) { _, size in
                    player.updateCanvasSize(to: size)
                }
        }
        .onDisappear {
            player.stop()
        }
    }
}

// MARK: - Convenience Initializers (Default Trigger)

public extension ConfettiScreen where Trigger == ConfettiTriggerButton {
    /// Creates a confetti view with the default trigger button.
    ///
    /// Customize the button style using `.confettiTriggerButtonStyle(_:)` modifier.
    ///
    /// ```swift
    /// ConfettiScreen(player)
    ///     .confettiTriggerButtonStyle(.init(text: "Party!"))
    /// ```
    ///
    /// - Parameter player: The player that controls the playback
    init(_ player: ConfettiPlayer) {
        self.init(
            player,
            triggerAlignment: .bottom,
            triggerPadding: EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
        ) { _, play in
            ConfettiTriggerButton(action: play)
        }
    }

    /// Creates a confetti view with default Player and trigger button.
    ///
    /// Customize the button style using `.confettiTriggerButtonStyle(_:)` modifier.
    ///
    /// ```swift
    /// ConfettiScreen()
    ///     .confettiTriggerButtonStyle(.init(
    ///         text: "Celebrate!",
    ///         gradientColors: [.purple, .pink]
    ///     ))
    /// ```
    init() {
        self.init(ConfettiPlayer())
    }
}

// MARK: - Convenience Initializers (Custom Trigger)

public extension ConfettiScreen {
    /// Creates a confetti view with default Player and custom trigger.
    /// - Parameters:
    ///   - triggerAlignment: Alignment of the trigger overlay (default: `.bottom`)
    ///   - triggerPadding: Padding around the trigger (default: bottom 50)
    ///   - trigger: A view builder that receives canvas size and play action
    init(
        triggerAlignment: Alignment = .bottom,
        triggerPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0),
        @ViewBuilder trigger: @escaping (_ canvasSize: CGSize, _ play: @escaping () -> Void) -> Trigger
    ) {
        self.init(
            ConfettiPlayer(),
            triggerAlignment: triggerAlignment,
            triggerPadding: triggerPadding,
            trigger: trigger
        )
    }
}

// MARK: - Previews

#Preview("Default") {
    ConfettiScreen()
}

#Preview("Custom Button Style") {
    ConfettiScreen()
        .confettiTriggerButtonStyle(.init(
            text: "Celebrate! 🎉",
            gradientColors: [.purple, .pink]
        ))
}

#Preview("Custom Trigger") {
    ConfettiScreen { _, play in
        Button("Tap Me") {
            play()
        }
        .buttonStyle(.borderedProminent)
    }
}
