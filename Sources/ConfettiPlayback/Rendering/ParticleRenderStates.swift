import Foundation

// MARK: - ParticleRenderStates

/// A zero-copy view into the active render states of a `ConfettiRenderer`.
///
/// This collection type provides efficient iteration over particle render states
/// without allocating a new array each time. It wraps the renderer's internal buffer
/// and exposes only the active portion.
///
/// ## Performance
///
/// Unlike returning `[ParticleRenderState]`, this type:
/// - **No allocation per access**: Simply wraps the existing buffer
/// - **O(1) count**: Precomputed from the renderer's active count
/// - **RandomAccessCollection**: Supports efficient indexed access and iteration
///
/// ## Usage
///
/// ```swift
/// let states = renderer.renderStates
/// for state in states {
///     // Draw particle
/// }
///
/// // Or indexed access
/// if !states.isEmpty {
///     let first = states[0]
/// }
/// ```
public struct ParticleRenderStates: RandomAccessCollection, Sendable {
    // MARK: - Types

    public typealias Element = ParticleRenderState
    public typealias Index = Int

    // MARK: - Properties

    /// Reference to the underlying buffer (shared, not copied)
    @usableFromInline
    let buffer: [ParticleRenderState]

    /// Number of active elements in the buffer
    @usableFromInline
    let activeCount: Int

    // MARK: - Initializer

    /// Creates a view into the given buffer with the specified active count.
    /// - Parameters:
    ///   - buffer: The underlying buffer (not copied, just referenced)
    ///   - activeCount: Number of active elements at the start of the buffer
    @inlinable
    init(buffer: [ParticleRenderState], activeCount: Int) {
        self.buffer = buffer
        self.activeCount = activeCount
    }

    /// Creates an empty collection.
    @inlinable
    public init() {
        self.buffer = []
        self.activeCount = 0
    }

    // MARK: - RandomAccessCollection

    @inlinable
    public var startIndex: Int { 0 }

    @inlinable
    public var endIndex: Int { activeCount }

    @inlinable
    public var count: Int { activeCount }

    @inlinable
    public var isEmpty: Bool { activeCount == 0 }

    @inlinable
    public subscript(position: Int) -> ParticleRenderState {
        precondition(position >= 0 && position < activeCount, "Index out of bounds")
        return buffer[position]
    }

    @inlinable
    public func index(after i: Int) -> Int { i + 1 }

    @inlinable
    public func index(before i: Int) -> Int { i - 1 }

    // MARK: - Convenience

    /// Converts to an array (allocates new memory).
    ///
    /// Use this only when you need to store the states or pass to APIs requiring `Array`.
    /// For iteration, use the collection directly.
    @inlinable
    public func toArray() -> [ParticleRenderState] {
        Array(buffer.prefix(activeCount))
    }
}

// MARK: Equatable

extension ParticleRenderStates: Equatable {
    public static func == (lhs: ParticleRenderStates, rhs: ParticleRenderStates) -> Bool {
        guard lhs.activeCount == rhs.activeCount else { return false }
        // Compare by ID for identity check (faster than full comparison)
        for i in 0 ..< lhs.activeCount where lhs.buffer[i].id != rhs.buffer[i].id {
            return false
        }
        return true
    }
}
