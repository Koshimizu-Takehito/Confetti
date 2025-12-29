import CoreGraphics
import Foundation

// MARK: - ConfettiConfig

/// Configuration values that define confetti animation behavior.
///
/// Use one of the provided presets for common scenarios, or customize individual properties
/// through the nested configuration structs.
///
/// ## Presets
///
/// ```swift
/// // Explosive celebration (default)
/// let config = ConfettiConfig.celebration
///
/// // Subtle, elegant effect
/// let config = ConfettiConfig.subtle
///
/// // Maximum impact
/// let config = ConfettiConfig.explosion
///
/// // Gentle falling effect
/// let config = ConfettiConfig.snowfall
/// ```
///
/// ## Custom Configuration
///
/// Customize individual aspects using nested configuration structs:
///
/// ```swift
/// var config = ConfettiConfig()
/// config.lifecycle.particleCount = 200
/// config.lifecycle.duration = 5.0
/// config.physics.gravity = 1500
/// config.spawn.speedRange = 2000...4500
/// ```
///
/// ## Configuration Categories
///
/// - ``Lifecycle``: Particle count, duration, and fade-out timing
/// - ``Physics``: Gravity, drag, terminal velocity, and simulation timing
/// - ``Spawn``: Origin position, initial velocity, and angle distribution
/// - ``Appearance``: Particle size and rotation speeds
/// - ``Wind``: Wind force and variation parameters
public struct ConfettiConfig: Sendable {
    // MARK: - Nested Types

    /// Lifecycle configuration for particle generation and duration.
    public struct Lifecycle: Sendable {
        /// Number of particles to generate.
        ///
        /// Higher values create denser confetti effects but may impact performance.
        /// - Default: 150
        public var particleCount: Int = 150

        /// Total duration of the animation in seconds.
        ///
        /// After this time, the simulation stops automatically.
        /// - Default: 3.0
        public var duration: TimeInterval = 3.0

        /// Duration of the fade-out effect before the animation ends.
        ///
        /// Particles begin fading out at `duration - fadeOutDuration`.
        /// - Default: 1.0
        public var fadeOutDuration: TimeInterval = 1.0

        public init() {}
    }

    /// Physics configuration for particle movement simulation.
    public struct Physics: Sendable {
        /// Gravitational acceleration (positive downward).
        ///
        /// Higher values make particles fall faster.
        /// - Default: 2500
        public var gravity: CGFloat = 2500

        /// Velocity decay coefficient (0 to 1).
        ///
        /// Values closer to 1 mean less decay (particles maintain velocity longer).
        /// Lower values create stronger air resistance.
        /// - Default: 0.88
        public var drag: CGFloat = 0.88

        /// Maximum falling velocity.
        ///
        /// Particles will not accelerate beyond this speed when falling.
        /// - Default: 150
        public var terminalVelocity: CGFloat = 150

        /// Fixed time step for physics simulation in seconds.
        ///
        /// This ensures consistent animation speed across different refresh rates.
        /// - Default: 1.0/60.0 (60 FPS)
        public var fixedDeltaTime: TimeInterval = 1.0 / 60.0

        public init() {}
    }

    /// Spawn configuration for particle initial state.
    public struct Spawn: Sendable {
        /// Margin for out-of-bounds detection in points.
        ///
        /// Particles are removed when they move beyond the bounds plus this margin.
        /// - Default: 150
        public var boundaryMargin: CGFloat = 150

        /// Height ratio of the launch position (0 = top, 1 = bottom).
        ///
        /// Determines where particles originate on the screen.
        /// - Default: 0.6 (60% from top)
        public var originHeightRatio: CGFloat = 0.6

        /// Initial velocity range in points per second.
        ///
        /// Higher values create more explosive effects.
        /// - Default: 1800...4000
        public var speedRange: ClosedRange<Double> = 1800 ... 4000

        /// Center of launch angle in radians.
        ///
        /// - -π/2 = upward
        /// - 0 = rightward
        /// - π/2 = downward
        /// - Default: -π/2 (upward)
        public var angleCenter: Double = -Double.pi / 2

        /// Spread of launch angle (± this value from center) in radians.
        ///
        /// Larger values create wider spread patterns.
        /// - Default: π/3 (60°)
        public var angleSpread: Double = .pi / 3

        public init() {}
    }

    /// Appearance configuration for particle visual properties.
    public struct Appearance: Sendable {
        /// Base size range for particles in points.
        ///
        /// The actual size is further modified by width and height scale factors.
        /// - Default: 8...16
        public var baseSizeRange: ClosedRange<CGFloat> = 8 ... 16

        /// Width scale factor range.
        ///
        /// Applied to the base size to determine final width.
        /// Values > 1 create wider particles; < 1 create narrower ones.
        /// - Default: 0.5...2.0
        public var widthScaleRange: ClosedRange<CGFloat> = 0.5 ... 2.0

        /// Height scale factor range.
        ///
        /// Applied to the base size to determine final height.
        /// - Default: 0.4...1.2
        public var heightScaleRange: ClosedRange<CGFloat> = 0.4 ... 1.2

        /// X-axis rotation speed range in radians per second.
        ///
        /// Creates the "flutter" effect as particles fall.
        /// - Default: 2.0...6.0
        public var rotationXSpeedRange: ClosedRange<Double> = 2.0 ... 6.0

        /// Y-axis rotation speed range in radians per second.
        ///
        /// Creates the "flip" effect as particles rotate.
        /// - Default: 1.5...5.0
        public var rotationYSpeedRange: ClosedRange<Double> = 1.5 ... 5.0

        public init() {}
    }

    /// Wind configuration for particle movement variation.
    public struct Wind: Sendable {
        /// Wind force range (positive = right, negative = left).
        ///
        /// Creates horizontal swaying motion during fall.
        /// - Default: -150...150
        public var forceRange: ClosedRange<Double> = -150 ... 150

        /// Wind variation period scale.
        ///
        /// Controls how quickly the wind direction oscillates.
        /// - Default: 3.0
        public var timeScale: Double = 3.0

        /// Wind phase offset per particle.
        ///
        /// Creates variation between particles so they don't all sway in sync.
        /// - Default: 0.3
        public var particlePhaseScale: Double = 0.3

        public init() {}
    }

    // MARK: - Properties

    /// Lifecycle configuration (particle count, duration, fade-out).
    public var lifecycle = Lifecycle()

    /// Physics configuration (gravity, drag, terminal velocity).
    public var physics = Physics()

    /// Spawn configuration (origin, velocity, angle).
    public var spawn = Spawn()

    /// Appearance configuration (size, rotation).
    public var appearance = Appearance()

    /// Wind configuration (force, variation).
    public var wind = Wind()

    // MARK: - Initializer

    /// Creates a configuration with default values.
    public init() {}

    // MARK: - Validation

    /// Returns a validated copy of the configuration with invalid values clamped to safe ranges.
    ///
    /// In DEBUG builds, assertions are triggered for invalid values to help catch configuration
    /// errors during development. In RELEASE builds, invalid values are silently clamped.
    ///
    /// This method ensures all configuration values are within acceptable bounds:
    /// - `lifecycle.particleCount`: Clamped to 0 or greater
    /// - `lifecycle.duration`: Clamped to 0.1 seconds or greater
    /// - `lifecycle.fadeOutDuration`: Clamped to 0...duration
    /// - `physics.fixedDeltaTime`: Clamped to 1/240 seconds or greater
    /// - `physics.drag`: Clamped to 0...1
    /// - `spawn.boundaryMargin`: Clamped to 0 or greater
    ///
    /// - Returns: A new configuration with validated values
    public func validated() -> Self {
        // DEBUG assertions for early detection of configuration errors
        #if DEBUG
        assert(lifecycle.particleCount >= 0, "particleCount must be non-negative")
        assert(lifecycle.duration > 0, "duration must be positive")
        assert(lifecycle.fadeOutDuration >= 0, "fadeOutDuration must be non-negative")
        assert(lifecycle.fadeOutDuration <= lifecycle.duration, "fadeOutDuration must not exceed duration")
        assert(physics.fixedDeltaTime > 0, "fixedDeltaTime must be positive")
        assert(physics.drag >= 0 && physics.drag <= 1, "drag must be between 0 and 1")
        assert(spawn.boundaryMargin >= 0, "boundaryMargin must be non-negative")
        #endif

        var config = self

        // Lifecycle validation
        config.lifecycle.particleCount = max(0, config.lifecycle.particleCount)
        config.lifecycle.duration = max(0.1, config.lifecycle.duration)
        config.lifecycle.fadeOutDuration = max(0, min(config.lifecycle.fadeOutDuration, config.lifecycle.duration))

        // Physics validation
        config.physics.fixedDeltaTime = max(1.0 / 240.0, config.physics.fixedDeltaTime)
        config.physics.drag = max(0, min(1, config.physics.drag))

        // Spawn validation
        config.spawn.boundaryMargin = max(0, config.spawn.boundaryMargin)

        return config
    }
}

// MARK: - Presets

public extension ConfettiConfig {
    /// Standard celebration preset - balanced and festive.
    ///
    /// Good for general-purpose celebrations like achievements or completions.
    ///
    /// - Particle count: 150
    /// - Duration: 3 seconds
    /// - Balanced physics for natural-looking confetti
    static let celebration = ConfettiConfig()

    /// Subtle preset - gentle and elegant.
    ///
    /// Fewer particles with slower movement. Ideal for understated celebrations
    /// or backgrounds that shouldn't distract from content.
    ///
    /// - Particle count: 50
    /// - Duration: 4 seconds
    /// - Slower velocity and gentler physics
    static var subtle: ConfettiConfig {
        var config = ConfettiConfig()
        config.lifecycle.particleCount = 50
        config.lifecycle.duration = 4.0
        config.physics.gravity = 1200
        config.physics.drag = 0.92
        config.spawn.speedRange = 800 ... 1500
        config.appearance.baseSizeRange = 6 ... 12
        config.appearance.rotationXSpeedRange = 1.0 ... 3.0
        config.appearance.rotationYSpeedRange = 0.8 ... 2.5
        config.wind.forceRange = -50 ... 50
        return config
    }

    /// Explosion preset - maximum impact.
    ///
    /// Many particles with high velocity. Great for major achievements
    /// or dramatic moments that deserve attention.
    ///
    /// - Particle count: 300
    /// - Duration: 4 seconds
    /// - High velocity and strong physics
    static var explosion: ConfettiConfig {
        var config = ConfettiConfig()
        config.lifecycle.particleCount = 300
        config.lifecycle.duration = 4.0
        config.physics.gravity = 3000
        config.physics.drag = 0.85
        config.spawn.speedRange = 2500 ... 5000
        config.spawn.angleSpread = .pi / 2.5
        config.appearance.baseSizeRange = 10 ... 20
        config.appearance.rotationXSpeedRange = 3.0 ... 8.0
        config.appearance.rotationYSpeedRange = 2.0 ... 6.0
        config.wind.forceRange = -200 ... 200
        return config
    }

    /// Snowfall preset - gentle falling effect.
    ///
    /// Particles fall slowly from above with gentle swaying.
    /// Creates a calm, ambient atmosphere.
    ///
    /// - Particle count: 80
    /// - Duration: 6 seconds
    /// - Origin at top, downward angle, slow velocity
    static var snowfall: ConfettiConfig {
        var config = ConfettiConfig()
        config.lifecycle.particleCount = 80
        config.lifecycle.duration = 6.0
        config.physics.gravity = 400
        config.physics.drag = 0.98
        config.physics.terminalVelocity = 80
        config.spawn.originHeightRatio = 0.0
        config.spawn.speedRange = 100 ... 300
        config.spawn.angleCenter = .pi / 2 // Downward
        config.spawn.angleSpread = .pi / 6
        config.appearance.baseSizeRange = 8 ... 14
        config.appearance.rotationXSpeedRange = 0.5 ... 2.0
        config.appearance.rotationYSpeedRange = 0.3 ... 1.5
        config.wind.forceRange = -100 ... 100
        config.wind.timeScale = 2.0
        return config
    }
}
