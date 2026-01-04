import ConfettiPlayback
import Observation
import SwiftUI

// MARK: - ShaderEffectDemoViewModel

/// View model for the SwiftUI Shader Effect demonstration.
///
/// This view model wraps `ConfettiPlayer` and provides render states
/// that can be encoded as a float array for the Metal shader.
@MainActor
@Observable
final class ShaderEffectDemoViewModel {
    // MARK: - Properties

    /// The confetti player instance.
    private var player = ConfettiPlayer()

    /// The current render states for display.
    var renderStates: [ParticleRenderState] {
        player.simulation.renderStates
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
