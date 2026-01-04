import CoreGraphics
import Foundation
import Observation

// MARK: - ConfettiSimulation

// swiftlint:disable type_body_length
// Justification: Core physics simulation class with 10 focused helper methods (304 lines).
// Already refactored in commit 78ab1fe. Further splitting would create unnecessary abstraction.

/// State machine for confetti simulation.
///
/// Handles particle creation, updates, and termination. UI-independent.
/// Uses `ConfettiCloud` which separates immutable attributes (Traits) and mutable state (State).
@MainActor
@Observable public final class ConfettiSimulation {
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
        public var lastUpdateTime: Date?
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

    public private(set) var configuration: ConfettiConfig
    public private(set) var state: State
    @ObservationIgnored private let renderer: ConfettiRenderer

    // MARK: - Render States Cache

    /// Cached render states (invalidated when cloud version changes)
    @ObservationIgnored private var cachedRenderStates: [ParticleRenderState] = []

    /// Last cloud version used for caching
    @ObservationIgnored private var lastCloudVersion: Int = -1

    /// Total duration of the simulation
    public var duration: TimeInterval { configuration.lifecycle.duration }

    /// Current simulation time
    public var currentTime: TimeInterval { state.simulationTime }

    /// Render states for Canvas drawing (cached, recomputed only when cloud changes)
    public var renderStates: [ParticleRenderState] {
        guard let cloud = state.cloud else { return [] }

        // Return cached result if cloud hasn't changed
        if cloud.version == lastCloudVersion {
            return cachedRenderStates
        }

        // Recompute and cache
        cachedRenderStates = renderer.update(from: cloud)
        lastCloudVersion = cloud.version
        return cachedRenderStates
    }

    // MARK: - Initialization

    /// Initializes with the specified configuration.
    ///
    /// The configuration is automatically validated to ensure safe values.
    /// Invalid values are clamped to acceptable ranges.
    public init(configuration: ConfettiConfig = .init()) {
        self.configuration = configuration.validated()
        self.state = .init()
        self.renderer = ConfettiRenderer(initialCapacity: configuration.lifecycle.particleCount)
    }

    // MARK: - Lifecycle

    /// Starts the simulation and generates particles.
    /// - Parameters:
    ///   - area: Size of the simulation area
    ///   - startTime: Start time
    ///   - colorSource: Color source
    ///   - randomNumberGenerator: Random number generator
    public func start(
        area bounds: CGSize,
        at startTime: Date,
        colorSource: some ConfettiColorSource,
        randomNumberGenerator numberGenerator: inout some RandomNumberGenerator
    ) {
        let origin = CGPoint(
            x: bounds.width / 2,
            y: bounds.height * configuration.spawn.originHeightRatio
        )
        let cloud = makeCloud(origin: origin, colorSource: colorSource, using: &numberGenerator)
        state.startTime = startTime
        state.lastUpdateTime = startTime
        state.simulationTime = 0
        state.accumulatedTime = 0
        state.isPaused = false
        state.initialCloud = cloud
        state.cloud = cloud
    }

    /// Stops the simulation and resets the state.
    public func stop() {
        state = .init()
        renderer.clear()
        cachedRenderStates = []
        lastCloudVersion = -1
    }

    /// Pauses the simulation.
    ///
    /// The simulation retains its current state and can be resumed with `resume(at:)`.
    public func pause() {
        guard state.isRunning, !state.isPaused else { return }
        state.isPaused = true
    }

    /// Resumes a paused simulation.
    /// - Parameter currentTime: Current time (used to synchronize frame timing)
    public func resume(at currentTime: Date) {
        guard state.isRunning, state.isPaused else { return }
        state.isPaused = false
        state.lastUpdateTime = currentTime
        state.accumulatedTime = 0
    }

    /// Seeks to a specific simulation time.
    ///
    /// This recomputes the simulation from the initial state to the target time.
    /// - Parameters:
    ///   - time: Target simulation time (clamped to 0...duration)
    ///   - area: Size of the simulation area
    public func seek(to time: TimeInterval, area bounds: CGSize) {
        guard state.isRunning, let initialCloud = state.initialCloud else { return }

        let targetTime = max(0, min(time, configuration.lifecycle.duration))

        // Reset to initial state
        var cloud = initialCloud
        cloud.incrementVersion()
        state.cloud = cloud
        state.simulationTime = 0
        state.accumulatedTime = 0

        // Fast-forward simulation to target time
        let fixedDeltaTime = configuration.physics.fixedDeltaTime
        guard fixedDeltaTime > 0 else { return }

        let stepsNeeded = Int(targetTime / fixedDeltaTime)
        for _ in 0 ..< stepsNeeded {
            state.simulationTime += fixedDeltaTime
            step(deltaTime: fixedDeltaTime, elapsed: state.simulationTime, area: bounds)
        }
    }

    /// Advances the simulation by one frame.
    ///
    /// Automatically calls `stop()` if `duration` is exceeded.
    /// Does nothing if paused.
    /// - Parameters:
    ///   - currentTime: Current time
    ///   - area: Size of the simulation area (used for out-of-bounds detection)
    public func update(at currentTime: Date, area bounds: CGSize) {
        guard state.isPlaying else { return }
        guard let startTime = state.startTime else { return }

        // Check if simulation time exceeds duration
        if state.simulationTime >= configuration.lifecycle.duration {
            stop()
            return
        }

        // Also check wall-clock time as a fallback for edge cases
        let wallElapsed = currentTime.timeIntervalSince(startTime)
        if wallElapsed > configuration.lifecycle.duration + 1.0 {
            stop()
            return
        }

        // Convert variable refresh cadence (60/120Hz etc.) into a fixed-step simulation.
        let fixedDeltaTime = configuration.physics.fixedDeltaTime
        guard fixedDeltaTime > 0 else { return }

        let lastUpdate = state.lastUpdateTime ?? currentTime
        var frameDelta = currentTime.timeIntervalSince(lastUpdate)
        state.lastUpdateTime = currentTime

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
            step(deltaTime: fixedDeltaTime, elapsed: state.simulationTime, area: bounds)
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
    ///
    /// - Important: This method increments the cloud version to invalidate render state cache.
    package func withCloudForTesting(_ body: (inout ConfettiCloud) -> Void) {
        guard var cloud = state.cloud else { return }
        body(&cloud)
        cloud.incrementVersion()
        state.cloud = cloud
    }
    #endif

    // MARK: - Private - Cloud Creation

    private func makeCloud(
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

    private func step(deltaTime: TimeInterval, elapsed: TimeInterval, area bounds: CGSize) {
        guard var cloud = state.cloud else { return }

        for index in 0 ..< cloud.aliveCount {
            let traits = cloud.traits[index]
            var particleState = cloud.states[index]

            // 1. Apply physics forces
            applyGravity(to: &particleState, deltaTime: deltaTime)
            let windVariation = applyWind(
                to: &particleState,
                traits: traits,
                elapsed: elapsed,
                particleIndex: index,
                deltaTime: deltaTime
            )
            applyDrag(to: &particleState)
            clampTerminalVelocity(of: &particleState)

            // 2. Update motion
            updatePosition(of: &particleState, deltaTime: deltaTime)

            // 3. Check boundaries
            if isOutOfBounds(particleState, area: bounds) {
                particleState.opacity = 0
                cloud.states[index] = particleState
                continue
            }

            // 4. Update rotation
            updateRotation(
                of: &particleState,
                traits: traits,
                windVariation: windVariation,
                deltaTime: deltaTime
            )

            // 5. Apply fade-out
            applyFadeOut(to: &particleState, elapsed: elapsed)

            cloud.states[index] = particleState
        }

        cloud.compact()
        cloud.incrementVersion()
        state.cloud = cloud
    }

    // MARK: - Physics Forces

    /// Applies gravity to particle velocity.
    private func applyGravity(to state: inout ConfettoState, deltaTime: TimeInterval) {
        state.velocity.dy += configuration.physics.gravity * deltaTime
    }

    /// Applies wind force to particle velocity and returns the wind variation for rotation calculation.
    /// - Returns: Current wind strength (used in rotation calculation)
    private func applyWind(
        to state: inout ConfettoState,
        traits: ConfettoTraits,
        elapsed: TimeInterval,
        particleIndex: Int,
        deltaTime: TimeInterval
    ) -> Double {
        let windVariation = sin(
            elapsed * configuration.wind.timeScale +
                Double(particleIndex) * configuration.wind.particlePhaseScale
        ) * traits.windForce

        state.velocity.dx += windVariation * deltaTime
        return windVariation
    }

    /// Applies drag (air resistance) to particle velocity.
    private func applyDrag(to state: inout ConfettoState) {
        state.velocity.dx *= configuration.physics.drag
        state.velocity.dy *= configuration.physics.drag
    }

    /// Limits terminal velocity (falling direction only).
    private func clampTerminalVelocity(of state: inout ConfettoState) {
        if state.velocity.dy > configuration.physics.terminalVelocity {
            state.velocity.dy = configuration.physics.terminalVelocity
        }
    }

    // MARK: - Motion

    /// Updates particle position based on velocity.
    private func updatePosition(of state: inout ConfettoState, deltaTime: TimeInterval) {
        state.position.x += state.velocity.dx * deltaTime
        state.position.y += state.velocity.dy * deltaTime
    }

    // MARK: - Boundaries

    /// Checks if particle has moved outside the simulation area.
    private func isOutOfBounds(_ state: ConfettoState, area bounds: CGSize) -> Bool {
        let margin = configuration.spawn.boundaryMargin
        return state.position.y < -margin
            || state.position.y > bounds.height + margin
            || state.position.x < -margin
            || state.position.x > bounds.width + margin
    }

    // MARK: - Rotation

    /// Updates particle rotation based on velocity, wind, and fast-fall effects.
    private func updateRotation(
        of state: inout ConfettoState,
        traits: ConfettoTraits,
        windVariation: Double,
        deltaTime: TimeInterval
    ) {
        updateRotationX(of: &state, traits: traits, windVariation: windVariation, deltaTime: deltaTime)
        updateRotationY(of: &state, traits: traits, windVariation: windVariation, deltaTime: deltaTime)
    }

    /// Updates X-axis rotation (flutter effect).
    private func updateRotationX(
        of state: inout ConfettoState,
        traits: ConfettoTraits,
        windVariation: Double,
        deltaTime: TimeInterval
    ) {
        // Base rotation speed
        var rotationSpeed = traits.rotationXSpeed

        // Velocity influence
        rotationSpeed += state.velocity.dy * RotationDynamics.velocityToRotationX

        // Wind influence
        rotationSpeed += windVariation * RotationDynamics.windToRotationX

        // Apply rotation
        state.rotationX += rotationSpeed * deltaTime

        // Additional rotation during fast fall
        let fallSpeed = abs(state.velocity.dy)
        if fallSpeed > RotationDynamics.fastFallThreshold {
            state.rotationX += fallSpeed * RotationDynamics.fastFallRotationX * deltaTime
        }
    }

    /// Updates Y-axis rotation (flip effect).
    private func updateRotationY(
        of state: inout ConfettoState,
        traits: ConfettoTraits,
        windVariation: Double,
        deltaTime: TimeInterval
    ) {
        // Base rotation speed
        var rotationSpeed = traits.rotationYSpeed

        // Velocity influence
        rotationSpeed += state.velocity.dx * RotationDynamics.velocityToRotationY

        // Wind influence
        rotationSpeed += windVariation * RotationDynamics.windToRotationY

        // Apply rotation
        state.rotationY += rotationSpeed * deltaTime

        // Additional rotation during fast fall
        let fallSpeed = abs(state.velocity.dy)
        if fallSpeed > RotationDynamics.fastFallThreshold {
            state.rotationY += fallSpeed * RotationDynamics.fastFallRotationY * deltaTime
        }
    }

    // MARK: - Lifecycle

    /// Applies fade-out effect during the last seconds of the simulation.
    private func applyFadeOut(to state: inout ConfettoState, elapsed: TimeInterval) {
        let fadeStart = configuration.lifecycle.duration - configuration.lifecycle.fadeOutDuration

        if elapsed > fadeStart {
            let fadeProgress = (elapsed - fadeStart) / configuration.lifecycle.fadeOutDuration
            state.opacity = max(0, 1.0 - fadeProgress)
        }
    }
}

// swiftlint:enable type_body_length
