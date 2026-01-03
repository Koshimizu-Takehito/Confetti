import ConfettiCore
import CoreGraphics
import Foundation
import Observation

// MARK: - ConfettiPlayer

/// Controls confetti playback.
///
/// Runs simulation with `ConfettiSimulation` and converts to render states with `ConfettiRenderer`.
/// Frame updates are controlled by internal `DisplayLinkDriver`.
///
/// Supports video-player-like controls:
/// - `play(canvasSize:)`: Start from beginning
/// - `pause()`: Pause playback
/// - `resume()`: Resume paused playback
/// - `seek(to:)`: Jump to specific time
/// - `stop()`: Stop and reset
///
/// ## Custom Colors
///
/// You can inject a custom color source to use your own palette:
///
/// ```swift
/// struct BrandColorSource: ConfettiColorSource {
///     let colors: [CGColor] = [
///         CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
///         CGColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1),
///     ]
///     mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor {
///         colors.randomElement(using: &numberGenerator)!
///     }
/// }
///
/// let player = ConfettiPlayer(colorSource: BrandColorSource())
/// ```
@MainActor
@Observable public final class ConfettiPlayer {
    // MARK: - Published State

    public private(set) var renderStates: [ParticleRenderState] = []

    // MARK: - Dependencies

    public let simulation: ConfettiSimulation
    @ObservationIgnored private var renderer: ConfettiRenderer
    @ObservationIgnored private var colorSource: any ConfettiColorSource
    @ObservationIgnored private var numberGenerator: any RandomNumberGenerator & Sendable
    @ObservationIgnored private let displayLinkDriver = DisplayLinkDriver()
    @ObservationIgnored private var canvasSize: CGSize = .zero

    // MARK: - Initializer

    /// Creates a player with the specified configuration, color source, and random number generator.
    ///
    /// - Parameters:
    ///   - configuration: Simulation configuration (default: `.init()`)
    ///   - colorSource: Color source for particle colors (default: `DefaultColorSource()`)
    ///   - numberGenerator: Random number generator for deterministic testing (default:
    /// `SystemRandomNumberGenerator()`)
    public init(
        configuration: ConfettiConfig = .init(),
        colorSource: some ConfettiColorSource = DefaultColorSource(),
        numberGenerator: some RandomNumberGenerator & Sendable = SystemRandomNumberGenerator()
    ) {
        self.simulation = ConfettiSimulation(configuration: configuration)
        self.renderer = ConfettiRenderer(initialCapacity: configuration.lifecycle.particleCount)
        self.colorSource = colorSource
        self.numberGenerator = numberGenerator
    }

    // MARK: - Playback Control

    /// Starts the playback from the beginning.
    /// - Parameter canvasSize: Size of the drawing area
    public func play(canvasSize size: CGSize) {
        canvasSize = size
        simulation.start(area: size, at: .now, colorSource: colorSource, randomNumberGenerator: &numberGenerator)
        syncRenderStates()
        startDisplayLink()
    }

    /// Pauses the playback.
    ///
    /// The playback retains its current state and can be resumed with `resume()`.
    public func pause() {
        simulation.pause()
        displayLinkDriver.stop()
        syncRenderStates()
    }

    /// Resumes a paused playback.
    public func resume() {
        guard simulation.state.isPaused else { return }
        simulation.resume(at: .now)
        syncRenderStates()
        startDisplayLink()
    }

    /// Seeks to a specific time.
    /// - Parameter time: Target time (clamped to 0...duration)
    public func seek(to time: TimeInterval) {
        simulation.seek(to: time, area: canvasSize)
        syncRenderStates()
    }

    /// Stops the playback and resets the state.
    public func stop() {
        displayLinkDriver.stop()
        simulation.stop()
        syncRenderStates()
    }

    /// Notifies canvas size changes.
    /// - Parameter newSize: New canvas size
    public func updateCanvasSize(to newSize: CGSize) {
        canvasSize = newSize
    }

    // MARK: - Private

    private func startDisplayLink() {
        displayLinkDriver.start { [weak self] date in
            self?.tick(at: date)
        }
    }

    private func tick(at date: Date) {
        if simulation.state.isPlaying {
            simulation.update(at: date, area: canvasSize)
        } else {
            displayLinkDriver.stop()
        }
        syncRenderStates()
    }

    private func syncRenderStates() {
        if let cloud = simulation.state.cloud {
            renderStates = renderer.update(from: cloud)
        } else {
            renderer.clear()
            renderStates = []
        }
    }
}
