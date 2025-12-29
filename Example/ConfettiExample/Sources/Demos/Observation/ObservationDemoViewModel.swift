import ConfettiPlayback
import CoreGraphics
import Foundation

// MARK: - ObservationDemoViewModel

/// A view model demonstrating confetti playback using Swift's `@Observable` macro.
///
/// This view model showcases the recommended integration pattern for iOS 17+ projects.
/// It wraps ``ConfettiPlayer`` and exposes its render states as an observable property,
/// enabling automatic SwiftUI view updates without Combine or manual subscription.
///
/// ## Overview
///
/// The `@Observable` macro automatically synthesizes observation tracking,
/// making the `renderStates` property observable. When the underlying player
/// updates its particle states, SwiftUI views that access this property
/// will automatically re-render.
///
/// ## Example Usage
///
/// ```swift
/// @State private var viewModel = ObservationDemoViewModel()
///
/// var body: some View {
///     GeometryReader { geometry in
///         Canvas { context, _ in
///             for state in viewModel.renderStates {
///                 // Render particles...
///             }
///         }
///         .onTapGesture {
///             viewModel.fire()
///         }
///         .onChange(of: geometry.size) { _, size in
///             viewModel.canvasSize = size
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``ObservationDemoView``
/// - SeeAlso: ``ObservableObjectDemoViewModel`` for backward-compatible alternative
@MainActor
@Observable
final class ObservationDemoViewModel {
    // MARK: - Properties

    /// The underlying confetti player managing simulation and rendering.
    private let player = ConfettiPlayer()

    /// The size of the canvas where confetti will be rendered.
    ///
    /// Set this property when the view's geometry changes to ensure particles
    /// are rendered within the correct bounds.
    var canvasSize: CGSize = .zero {
        didSet {
            player.updateCanvasSize(to: canvasSize)
        }
    }

    /// The current list of particle render states.
    ///
    /// This computed property forwards the player's render states, enabling
    /// automatic observation tracking when accessed from a SwiftUI view.
    var renderStates: [ParticleRenderState] {
        player.renderStates
    }

    // MARK: - Playback Control

    /// Fires a burst of confetti particles.
    ///
    /// Calling this method resets the simulation and begins a new confetti animation.
    /// Make sure to set ``canvasSize`` before calling this method.
    func fire() {
        player.play(canvasSize: canvasSize)
    }

    /// Stops the confetti animation and clears all particles.
    ///
    /// Use this method to clean up resources when the view disappears
    /// or when the animation should be terminated.
    func stop() {
        player.stop()
    }
}
