import Foundation

// MARK: - ConfettiCloud

/// Collection of confetto pieces.
///
/// Separates immutable `traits` and mutable `states`.
/// Manages alive particles from the beginning of arrays using `aliveCount`.
///
/// ## Design Intent
///
/// - **Separation of immutable/mutable**: `traits` are determined at creation, `states` are updated every frame
/// - **Compaction**: Dead particles are moved to the end of arrays and `aliveCount` is decremented
public struct ConfettiCloud: Sendable {
    // MARK: - Immutable

    /// Immutable attributes of each confetto piece
    public private(set) var traits: [ConfettoTraits]

    // MARK: - Mutable

    /// Dynamic state of each confetto piece
    public var states: [ConfettoState]

    /// Number of alive particles
    ///
    /// `traits[0..<aliveCount]` and `states[0..<aliveCount]` are valid.
    public var aliveCount: Int

    /// Version counter for cache invalidation.
    ///
    /// This counter is incremented whenever the cloud state is mutated,
    /// enabling efficient cache invalidation in consumers (e.g., `ConfettiSimulation.renderStates`).
    public private(set) var version: Int = 0

    // MARK: - Computed

    /// Whether there are no particles remaining
    public var isEmpty: Bool { aliveCount == 0 }

    /// Initial capacity
    public var capacity: Int { traits.count }

    // MARK: - Initializer

    /// Initializes with the specified attributes and states.
    /// - Parameters:
    ///   - traits: Immutable attributes of each confetto piece
    ///   - states: Initial state of each confetto piece
    ///   - aliveCount: Number of alive particles (typically `traits.count`)
    public init(traits: [ConfettoTraits], states: [ConfettoState], aliveCount: Int) {
        precondition(traits.count == states.count, "traits and states must have the same count")
        precondition(aliveCount <= traits.count, "aliveCount must be less than or equal to traits.count")
        self.traits = traits
        self.states = states
        self.aliveCount = aliveCount
        self.version = 0
    }

    // MARK: - Mutation Tracking

    /// Increments the version counter.
    ///
    /// This should be called after any mutation to the cloud state to invalidate caches.
    public mutating func incrementVersion() {
        version += 1
    }

    // MARK: - Compaction

    /// Removes dead particles and compacts the arrays.
    ///
    /// Moves particles with opacity <= 0 to the end of arrays and updates `aliveCount`.
    public mutating func compact() {
        var writeIndex = 0
        for readIndex in 0 ..< aliveCount {
            guard states[readIndex].opacity > 0 else { continue }
            if writeIndex != readIndex {
                traits[writeIndex] = traits[readIndex]
                states[writeIndex] = states[readIndex]
            }
            writeIndex += 1
        }
        aliveCount = writeIndex
    }
}
