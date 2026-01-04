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

    /// Rotation speed (dx: X-axis, dy: Y-axis) in radians per second
    public let rotationSpeed: CGVector

    /// Wind influence factor
    public let windForce: Double

    /// Initializes with the specified parameters.
    public init(
        id: UUID = UUID(),
        width: CGFloat,
        height: CGFloat,
        color: CGColor,
        rotationSpeed: CGVector,
        windForce: Double
    ) {
        self.id = id
        self.width = width
        self.height = height
        self.color = color
        self.rotationSpeed = rotationSpeed
        self.windForce = windForce
    }

    /// Initializes with separate rotation speed components (compatibility).
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
        self.rotationSpeed = CGVector(dx: rotationXSpeed, dy: rotationYSpeed)
        self.windForce = windForce
    }

    /// X-axis rotation speed in radians per second (computed property for convenience).
    public var rotationXSpeed: Double {
        rotationSpeed.dx
    }

    /// Y-axis rotation speed in radians per second (computed property for convenience).
    public var rotationYSpeed: Double {
        rotationSpeed.dy
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

    /// Rotation (dx: X-axis rotation, dy: Y-axis rotation) in radians
    public var rotation: CGVector

    /// Opacity (0 to 1)
    public var opacity: Double

    /// Initializes with the specified parameters.
    public init(
        position: CGPoint,
        velocity: CGVector,
        rotation: CGVector,
        opacity: Double = 1.0
    ) {
        self.position = position
        self.velocity = velocity
        self.rotation = rotation
        self.opacity = opacity
    }

    /// Initializes with separate rotation components (compatibility).
    public init(
        position: CGPoint,
        velocity: CGVector,
        rotationX: Double,
        rotationY: Double,
        opacity: Double = 1.0
    ) {
        self.position = position
        self.velocity = velocity
        self.rotation = CGVector(dx: rotationX, dy: rotationY)
        self.opacity = opacity
    }

    /// X-axis rotation in radians (computed property for convenience).
    public var rotationX: Double {
        get { rotation.dx }
        set { rotation.dx = newValue }
    }

    /// Y-axis rotation in radians (computed property for convenience).
    public var rotationY: Double {
        get { rotation.dy }
        set { rotation.dy = newValue }
    }
}
