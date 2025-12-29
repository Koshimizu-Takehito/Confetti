import CoreGraphics
import Foundation

// MARK: - ConfettiSimulation

/// State machine for confetti simulation.
///
/// Handles particle creation, updates, and termination. UI-independent.
/// Uses `ConfettiCloud` which separates immutable attributes (Traits) and mutable state (State).
public struct ConfettiSimulation: Sendable {
    // MARK: - Rotation Dynamics Constants

    /// Coefficients for velocity-to-rotation effects
    private enum RotationDynamics {
        /// Y velocity → X rotation coefficient
        static let velocityToRotationX: Double = 0.01
        /// X velocity → Y rotation coefficient
        static let velocityToRotationY: Double = 0.008
        /// Wind → X rotation coefficient
        static let windToRotationX: Double = 0.05
        /// Wind → Y rotation coefficient
        static let windToRotationY: Double = 0.03
        /// Velocity threshold for fast fall detection
        static let fastFallThreshold: CGFloat = 10
        /// Additional X rotation coefficient during fast fall
        static let fastFallRotationX: Double = 0.0005
        /// Additional Y rotation coefficient during fast fall
        static let fastFallRotationY: Double = 0.0003
    }

    // MARK: - Nested Types

    /// Simulation state
    public struct State: Sendable {
        public var startTime: Date?
        public var lastTickTime: Date?
        public var cloud: ConfettiCloud?
        /// Initial cloud state for seek operations
        public var initialCloud: ConfettiCloud?
        /// Simulation time advanced by fixed steps (seconds).
        public var simulationTime: TimeInterval = 0
        /// Accumulator for real time deltas (seconds).
        public var accumulatedTime: TimeInterval = 0
        /// Whether the simulation is paused
        public var isPaused: Bool = false

        public init() {}

        /// Whether the simulation is running (started and not stopped)
        public var isRunning: Bool { startTime != nil }

        /// Whether the simulation is actively playing (running and not paused)
        public var isPlaying: Bool { isRunning && !isPaused }
    }

    // MARK: - Properties

    public var configuration: ConfettiConfig
    public private(set) var state: State

    /// Total duration of the simulation
    public var duration: TimeInterval { configuration.lifecycle.duration }

    /// Current simulation time
    public var currentTime: TimeInterval { state.simulationTime }

    // MARK: - Initialization

    /// Initializes with the specified configuration.
    ///
    /// The configuration is automatically validated to ensure safe values.
    /// Invalid values are clamped to acceptable ranges.
    public init(configuration: ConfettiConfig = .init()) {
        self.configuration = configuration.validated()
        self.state = .init()
    }

    // MARK: - Lifecycle

    /// Starts the simulation and generates particles.
    /// - Parameters:
    ///   - bounds: Size of the simulation area
    ///   - at: Start time
    ///   - colorSource: Color source
    ///   - numberGenerator: Number generator
    public mutating func start(
        bounds: CGSize,
        at date: Date,
        colorSource: some ConfettiColorSource,
        using numberGenerator: inout some RandomNumberGenerator
    ) {
        let origin = CGPoint(
            x: bounds.width / 2,
            y: bounds.height * configuration.spawn.originHeightRatio
        )
        let cloud = makeCloud(origin: origin, colorSource: colorSource, using: &numberGenerator)
        state.startTime = date
        state.lastTickTime = date
        state.simulationTime = 0
        state.accumulatedTime = 0
        state.isPaused = false
        state.initialCloud = cloud
        state.cloud = cloud
    }

    /// Stops the simulation and resets the state.
    public mutating func stop() {
        state = .init()
    }

    /// Pauses the simulation.
    ///
    /// The simulation retains its current state and can be resumed with `resume(at:)`.
    public mutating func pause() {
        guard state.isRunning, !state.isPaused else { return }
        state.isPaused = true
    }

    /// Resumes a paused simulation.
    /// - Parameter date: Current time (used to synchronize frame timing)
    public mutating func resume(at date: Date) {
        guard state.isRunning, state.isPaused else { return }
        state.isPaused = false
        state.lastTickTime = date
        state.accumulatedTime = 0
    }

    /// Seeks to a specific simulation time.
    ///
    /// This recomputes the simulation from the initial state to the target time.
    /// - Parameters:
    ///   - time: Target simulation time (clamped to 0...duration)
    ///   - bounds: Size of the simulation area
    public mutating func seek(to time: TimeInterval, bounds: CGSize) {
        guard state.isRunning, let initialCloud = state.initialCloud else { return }

        let targetTime = max(0, min(time, configuration.lifecycle.duration))

        // Reset to initial state
        state.cloud = initialCloud
        state.simulationTime = 0
        state.accumulatedTime = 0

        // Fast-forward simulation to target time
        let fixedDeltaTime = configuration.physics.fixedDeltaTime
        guard fixedDeltaTime > 0 else { return }

        let stepsNeeded = Int(targetTime / fixedDeltaTime)
        for _ in 0 ..< stepsNeeded {
            state.simulationTime += fixedDeltaTime
            step(deltaTime: fixedDeltaTime, elapsed: state.simulationTime, bounds: bounds)
        }
    }

    /// Advances the simulation by one frame.
    ///
    /// Automatically calls `stop()` if `duration` is exceeded.
    /// Does nothing if paused.
    /// - Parameters:
    ///   - at: Current time
    ///   - bounds: Size of the simulation area (used for out-of-bounds detection)
    public mutating func tick(at date: Date, bounds: CGSize) {
        guard state.isPlaying else { return }
        guard let startTime = state.startTime else { return }

        // Check if simulation time exceeds duration
        if state.simulationTime >= configuration.lifecycle.duration {
            stop()
            return
        }

        // Also check wall-clock time as a fallback for edge cases
        let wallElapsed = date.timeIntervalSince(startTime)
        if wallElapsed > configuration.lifecycle.duration + 1.0 {
            stop()
            return
        }

        // Convert variable refresh cadence (60/120Hz etc.) into a fixed-step simulation.
        let fixedDeltaTime = configuration.physics.fixedDeltaTime
        guard fixedDeltaTime > 0 else { return }

        let lastTick = state.lastTickTime ?? date
        var frameDelta = date.timeIntervalSince(lastTick)
        state.lastTickTime = date

        // Guard against large time jumps (backgrounding etc.)
        if frameDelta.isNaN || frameDelta.isInfinite { frameDelta = 0 }
        frameDelta = max(0, min(frameDelta, 0.25))

        state.accumulatedTime += frameDelta

        // Avoid spiral-of-death by limiting catch-up steps per tick.
        let maxStepsPerTick = 5
        // Date arithmetic can introduce tiny rounding errors; use a small epsilon so that
        // "exactly one fixed step" doesn't get floored to 0 due to floating-point drift.
        let epsilon: TimeInterval = 1e-6

        let availableSteps = Int((state.accumulatedTime + epsilon) / fixedDeltaTime)
        guard availableSteps > 0 else { return }

        let stepsToRun = min(availableSteps, maxStepsPerTick)
        for _ in 0 ..< stepsToRun {
            state.simulationTime += fixedDeltaTime
            step(deltaTime: fixedDeltaTime, elapsed: state.simulationTime, bounds: bounds)
        }
        state.accumulatedTime -= TimeInterval(stepsToRun) * fixedDeltaTime

        // If we couldn't catch up fully, drop the remainder to prevent runaway latency.
        if availableSteps > maxStepsPerTick {
            state.accumulatedTime = 0
        }
    }

    // MARK: - Testing Support

    #if DEBUG
    /// For testing: Directly manipulate the Cloud.
    public mutating func withCloudForTesting(_ body: (inout ConfettiCloud) -> Void) {
        guard var cloud = state.cloud else { return }
        body(&cloud)
        state.cloud = cloud
    }
    #endif

    // MARK: - Private - Cloud Creation

    private mutating func makeCloud(
        origin: CGPoint,
        colorSource: some ConfettiColorSource,
        using numberGenerator: inout some RandomNumberGenerator
    ) -> ConfettiCloud {
        var colorSource = colorSource
        var traits: [ConfettoTraits] = []
        var states: [ConfettoState] = []

        let particleCount = configuration.lifecycle.particleCount
        traits.reserveCapacity(particleCount)
        states.reserveCapacity(particleCount)

        for _ in 0 ..< particleCount {
            let (confettoTraits, confettoState) = makeConfetto(
                origin: origin,
                colorSource: &colorSource,
                using: &numberGenerator
            )
            traits.append(confettoTraits)
            states.append(confettoState)
        }

        return ConfettiCloud(traits: traits, states: states, aliveCount: particleCount)
    }

    private func makeConfetto(
        origin: CGPoint,
        colorSource: inout some ConfettiColorSource,
        using numberGenerator: inout some RandomNumberGenerator
    ) -> (ConfettoTraits, ConfettoState) {
        let angle = configuration.spawn.angleCenter + Double.random(
            in: -configuration.spawn.angleSpread ..< configuration.spawn.angleSpread,
            using: &numberGenerator
        )
        let speed = Double.random(in: configuration.spawn.speedRange, using: &numberGenerator)
        let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)

        let baseSize = CGFloat.random(in: configuration.appearance.baseSizeRange, using: &numberGenerator)
        let width = baseSize * CGFloat.random(in: configuration.appearance.widthScaleRange, using: &numberGenerator)
        let height = baseSize * CGFloat.random(in: configuration.appearance.heightScaleRange, using: &numberGenerator)

        let traits = ConfettoTraits(
            width: width,
            height: height,
            color: colorSource.nextColor(using: &numberGenerator),
            rotationXSpeed: .random(in: configuration.appearance.rotationXSpeedRange, using: &numberGenerator),
            rotationYSpeed: .random(in: configuration.appearance.rotationYSpeedRange, using: &numberGenerator),
            windForce: .random(in: configuration.wind.forceRange, using: &numberGenerator)
        )

        let state = ConfettoState(
            position: origin,
            velocity: velocity,
            rotationX: .random(in: 0 ... .pi * 2, using: &numberGenerator),
            rotationY: .random(in: 0 ... .pi * 2, using: &numberGenerator)
        )

        return (traits, state)
    }

    // MARK: - Private - Simulation Step

    private mutating func step(deltaTime: TimeInterval, elapsed: TimeInterval, bounds: CGSize) {
        guard var cloud = state.cloud else { return }

        for index in 0 ..< cloud.aliveCount {
            let traits = cloud.traits[index]
            var confetto = cloud.states[index]

            // Gravity
            confetto.velocity.dy += configuration.physics.gravity * deltaTime

            // Wind (sine wave)
            let windVariation = sin(
                elapsed * configuration.wind.timeScale + Double(index) * configuration.wind.particlePhaseScale
            ) * traits.windForce
            confetto.velocity.dx += windVariation * deltaTime

            // Drag
            confetto.velocity.dx *= configuration.physics.drag
            confetto.velocity.dy *= configuration.physics.drag

            // Terminal velocity (falling only)
            if confetto.velocity.dy > configuration.physics.terminalVelocity {
                confetto.velocity.dy = configuration.physics.terminalVelocity
            }

            // Position
            confetto.position.x += confetto.velocity.dx * deltaTime
            confetto.position.y += confetto.velocity.dy * deltaTime

            // Out-of-bounds removal
            let margin = configuration.spawn.boundaryMargin
            let isOffscreen = confetto.position.y < -margin
                || confetto.position.y > bounds.height + margin
                || confetto.position.x < -margin
                || confetto.position.x > bounds.width + margin
            if isOffscreen {
                confetto.opacity = 0
                cloud.states[index] = confetto
                continue
            }

            // Rotation (flutter)
            let xRotationFromVelocity = confetto.velocity.dy * RotationDynamics.velocityToRotationX
            let xRotationFromWind = windVariation * RotationDynamics.windToRotationX
            confetto.rotationX += (traits.rotationXSpeed + xRotationFromVelocity + xRotationFromWind) * deltaTime

            let yRotationFromVelocity = confetto.velocity.dx * RotationDynamics.velocityToRotationY
            let yRotationFromWind = windVariation * RotationDynamics.windToRotationY
            confetto.rotationY += (traits.rotationYSpeed + yRotationFromVelocity + yRotationFromWind) * deltaTime

            let fallSpeed = abs(confetto.velocity.dy)
            if fallSpeed > RotationDynamics.fastFallThreshold {
                confetto.rotationX += fallSpeed * RotationDynamics.fastFallRotationX * deltaTime
                confetto.rotationY += fallSpeed * RotationDynamics.fastFallRotationY * deltaTime
            }

            // Fade-out (last fadeOutDuration seconds)
            let fadeStart = configuration.lifecycle.duration - configuration.lifecycle.fadeOutDuration
            if elapsed > fadeStart {
                let fadeProgress = (elapsed - fadeStart) / configuration.lifecycle.fadeOutDuration
                confetto.opacity = max(0, 1.0 - fadeProgress)
            }

            cloud.states[index] = confetto
        }

        cloud.compact()
        state.cloud = cloud
    }
}
