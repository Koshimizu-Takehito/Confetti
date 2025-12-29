import CoreGraphics
import Foundation

// MARK: - ConfettoTraits

/// Immutable attributes of a single confetto piece.
///
/// Determined at creation time and remain unchanged during animation.
public struct ConfettoTraits: Sendable {
    /// Unique identifier
    public let id: UUID

    /// Width
    public let width: CGFloat

    /// Height
    public let height: CGFloat

    /// Fill color
    public let color: CGColor

    /// X-axis rotation speed (radians per second)
    public let rotationXSpeed: Double

    /// Y-axis rotation speed (radians per second)
    public let rotationYSpeed: Double

    /// Wind influence factor
    public let windForce: Double

    /// Initializes with the specified parameters.
    public init(
        id: UUID = UUID(),
        width: CGFloat,
        height: CGFloat,
        color: CGColor,
        rotationXSpeed: Double,
        rotationYSpeed: Double,
        windForce: Double
    ) {
        self.id = id
        self.width = width
        self.height = height
        self.color = color
        self.rotationXSpeed = rotationXSpeed
        self.rotationYSpeed = rotationYSpeed
        self.windForce = windForce
    }
}

// MARK: - ConfettoState

/// Dynamic state of a single confetto piece.
///
/// Updated every frame by physics simulation.
public struct ConfettoState: Sendable {
    /// Position
    public var position: CGPoint

    /// Velocity
    public var velocity: CGVector

    /// X-axis rotation (radians)
    public var rotationX: Double

    /// Y-axis rotation (radians)
    public var rotationY: Double

    /// Opacity (0 to 1)
    public var opacity: Double

    /// Initializes with the specified parameters.
    public init(
        position: CGPoint,
        velocity: CGVector,
        rotationX: Double,
        rotationY: Double,
        opacity: Double = 1.0
    ) {
        self.position = position
        self.velocity = velocity
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.opacity = opacity
    }
}
