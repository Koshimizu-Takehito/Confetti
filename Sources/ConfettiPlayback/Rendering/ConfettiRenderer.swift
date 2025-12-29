import ConfettiCore
import Foundation
import SwiftUI

// MARK: - ConfettiRenderer

/// Converts `ConfettiCloud` (domain model) to ``ParticleRenderState`` (for rendering).
///
/// Pseudo-3D rotation is achieved by calculating depth scale from Y rotation, and opacity/Z rotation from X rotation.
///
/// ## Performance Optimization
///
/// `ConfettiRenderer` maintains an internal buffer to avoid per-frame allocations.
/// The buffer is reused and resized only when the particle count increases.
///
/// ```swift
/// var renderer = ConfettiRenderer()
/// renderer.update(from: cloud)
/// let states = renderer.renderStates // No allocation if count hasn't increased
/// ```
public struct ConfettiRenderer: Sendable {
    // MARK: - Buffer

    /// Internal buffer for render states (reused across frames)
    private var buffer: [ParticleRenderState] = []

    /// Number of active render states in the buffer
    public private(set) var activeCount: Int = 0

    /// Current render states (view into the active portion of the buffer)
    public var renderStates: [ParticleRenderState] {
        Array(buffer.prefix(activeCount))
    }

    // MARK: - Initializer

    /// Creates a new renderer.
    /// - Parameter initialCapacity: Initial buffer capacity (default: 150, matching default particle count)
    public init(initialCapacity: Int = 150) {
        buffer.reserveCapacity(initialCapacity)
    }

    // MARK: - Update

    /// Updates the render states from the given cloud.
    ///
    /// This method reuses the internal buffer to minimize allocations.
    /// The buffer grows if needed but never shrinks automatically.
    ///
    /// - Parameter cloud: Source ConfettiCloud
    public mutating func update(from cloud: ConfettiCloud) {
        let count = cloud.aliveCount
        activeCount = count

        // Expand buffer if needed
        ensureCapacity(count)

        // Update existing elements in-place
        for index in 0 ..< count {
            let traits = cloud.traits[index]
            let state = cloud.states[index]
            updateRenderState(at: index, traits: traits, state: state)
        }
    }

    /// Clears all render states.
    public mutating func clear() {
        activeCount = 0
    }

    /// Resets the renderer and releases the buffer memory.
    public mutating func reset() {
        buffer.removeAll(keepingCapacity: false)
        activeCount = 0
    }

    // MARK: - Private

    private mutating func ensureCapacity(_ count: Int) {
        let currentCount = buffer.count
        if currentCount < count {
            // Append placeholder elements to expand the buffer
            let additional = count - currentCount
            buffer.append(contentsOf: repeatElement(ParticleRenderState(), count: additional))
        }
    }

    private mutating func updateRenderState(at index: Int, traits: ConfettoTraits, state: ConfettoState) {
        // Depth scale from Y rotation (0.5 to 1.0)
        let depthScale = 0.5 + 0.5 * abs(cos(state.rotationY))
        let scaledWidth = traits.width * depthScale
        let scaledHeight = traits.height * depthScale

        let rect = CGRect(
            x: state.position.x - scaledWidth / 2,
            y: state.position.y - scaledHeight / 2,
            width: scaledWidth,
            height: scaledHeight
        )

        // Opacity modulation from X rotation (0.7 to 1.0)
        let xRotationOpacity = 0.7 + 0.3 * abs(cos(state.rotationX))
        let opacity = max(0.0, min(1.0, state.opacity * xRotationOpacity))

        // Small Z rotation from X rotation (flutter effect)
        let zRotation = sin(state.rotationX) * 0.3

        buffer[index].id = traits.id
        buffer[index].rect = rect
        buffer[index].color = Color(cgColor: traits.color)
        buffer[index].opacity = opacity
        buffer[index].zRotation = zRotation
    }
}

// MARK: - Static Convenience (for simple use cases)

public extension ConfettiRenderer {
    /// Converts Cloud to render states (creates a new array each call).
    ///
    /// - Note: For better performance in animation loops, use an instance of
    ///   `ConfettiRenderer` and call `update(from:)` instead.
    ///
    /// - Parameter cloud: Source ConfettiCloud
    /// - Returns: Array of render states
    static func renderStates(from cloud: ConfettiCloud) -> [ParticleRenderState] {
        var renderer = ConfettiRenderer(initialCapacity: cloud.aliveCount)
        renderer.update(from: cloud)
        return renderer.renderStates
    }
}
