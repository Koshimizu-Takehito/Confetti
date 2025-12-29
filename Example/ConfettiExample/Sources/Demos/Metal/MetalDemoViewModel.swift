import ConfettiPlayback
import Observation
import SwiftUI

// MARK: - MetalDemoViewModel

/// View model for the Metal rendering demonstration.
///
/// This view model wraps `ConfettiPlayer` and provides render states
/// for Metal-based particle rendering.
@MainActor
@Observable
final class MetalDemoViewModel {
    // MARK: - Properties

    /// The confetti player instance.
    private var player = ConfettiPlayer()

    /// The current render states for display.
    var renderStates: [ParticleRenderState] {
        player.renderStates
    }

    /// The canvas size for particle spawning.
    var canvasSize: CGSize = .zero {
        didSet {
            player.updateCanvasSize(to: canvasSize)
        }
    }

    // MARK: - Actions

    /// Fires the confetti animation.
    func fire() {
        player.play(canvasSize: canvasSize)
    }

    /// Stops the confetti animation.
    func stop() {
        player.stop()
    }
}
