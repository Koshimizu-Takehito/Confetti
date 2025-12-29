import Combine
import ConfettiPlayback
import CoreGraphics
import Foundation

// MARK: - ObservableObjectDemoViewModel

/// A view model demonstrating confetti playback using the `ObservableObject` protocol.
///
/// This view model showcases a backward-compatible integration pattern for projects
/// that cannot yet adopt iOS 17's `@Observable` macro, or for codebases that
/// prefer Combine-based architectures.
///
/// ## Overview
///
/// Since ``ConfettiPlayer`` uses Swift's `@Observable` macro, this view model
/// bridges its observation to `@Published` properties using `withObservationTracking`.
/// This enables compatibility with `@StateObject` and `@ObservedObject` in SwiftUI.
///
/// ## Bridging Pattern
///
/// The view model uses a recursive tracking pattern:
///
/// ```swift
/// private func observeAndBridgeRenderStates() {
///     _ = withObservationTracking { player.renderStates } onChange: {
///         Task { @MainActor in
///             self.renderStates = player.renderStates
///             self.observeAndBridgeRenderStates() // Re-register for next change
///         }
///     }
/// }
/// ```
///
/// ## Example Usage
///
/// ```swift
/// @StateObject private var viewModel = ObservableObjectDemoViewModel()
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
/// - SeeAlso: ``ObservableObjectDemoView``
/// - SeeAlso: ``ObservationDemoViewModel`` for modern iOS 17+ alternative
@MainActor
final class ObservableObjectDemoViewModel: ObservableObject {
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
    /// This property is updated via manual observation bridging from the player's
    /// `@Observable` render states to Combine's `@Published` mechanism.
    @Published var renderStates: [ParticleRenderState] = []

    // MARK: - Initialization

    /// Creates a new view model and begins observing player state changes.
    init() {
        observeAndBridgeRenderStates()
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

    // MARK: - Private Methods

    /// Bridges `@Observable` render states to `@Published` using recursive observation.
    ///
    /// This method registers for observation changes on the player's render states.
    /// When a change is detected, it updates the published property and re-registers
    /// for the next change, creating a continuous observation bridge.
    private func observeAndBridgeRenderStates() {
        _ = withObservationTracking { player.renderStates } onChange: { [weak self, player] in
            Task { @MainActor [weak self, player] in
                self?.renderStates = player.renderStates
                self?.observeAndBridgeRenderStates()
            }
        }
    }
}
