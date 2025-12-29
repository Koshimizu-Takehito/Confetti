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
///     mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
///         colors.randomElement(using: &rng)!
///     }
/// }
///
/// let player = ConfettiPlayer(colorSource: BrandColorSource())
/// ```
@MainActor
@Observable public final class ConfettiPlayer {
    // MARK: - Published State

    public private(set) var renderStates: [ParticleRenderState] = []
    public private(set) var isRunning: Bool = false
    public private(set) var isPaused: Bool = false
    public private(set) var currentTime: TimeInterval = 0

    /// Total duration of the playback
    public var duration: TimeInterval { simulation.duration }

    // MARK: - Dependencies

    @ObservationIgnored private var simulation: ConfettiSimulation
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
        simulation.start(bounds: size, at: .now, colorSource: colorSource, using: &numberGenerator)
        syncState()
        startDisplayLink()
    }

    /// Pauses the playback.
    ///
    /// The playback retains its current state and can be resumed with `resume()`.
    public func pause() {
        simulation.pause()
        displayLinkDriver.stop()
        syncState()
    }

    /// Resumes a paused playback.
    public func resume() {
        guard simulation.state.isPaused else { return }
        simulation.resume(at: .now)
        syncState()
        startDisplayLink()
    }

    /// Seeks to a specific time.
    /// - Parameter time: Target time (clamped to 0...duration)
    public func seek(to time: TimeInterval) {
        simulation.seek(to: time, bounds: canvasSize)
        syncState()
    }

    /// Stops the playback and resets the state.
    public func stop() {
        displayLinkDriver.stop()
        simulation.stop()
        syncState()
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
        guard simulation.state.isPlaying else {
            displayLinkDriver.stop()
            syncState()
            return
        }
        simulation.tick(at: date, bounds: canvasSize)
        syncState()
    }

    private func syncState() {
        isRunning = simulation.state.isRunning
        isPaused = simulation.state.isPaused
        currentTime = simulation.currentTime
        if let cloud = simulation.state.cloud {
            renderer.update(from: cloud)
            renderStates = renderer.renderStates
        } else {
            renderer.clear()
            renderStates = []
        }
    }
}
