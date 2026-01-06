import CoreGraphics

// MARK: - CGPoint Arithmetic Extensions

public extension CGPoint {
    // MARK: - Initialization

    /// Creates a point from a vector.
    init(_ vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }

    /// Creates a point with the same scalar value for both components.
    init(scalar: CGFloat) {
        self.init(x: scalar, y: scalar)
    }

    // MARK: - Conversion

    /// Converts this point to a vector.
    var cgVector: CGVector {
        CGVector(dx: x, dy: y)
    }

    // MARK: - Arithmetic Operators

    /// Adds two points component-wise.
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtracts two points component-wise.
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Multiplies a point by a scalar.
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Multiplies a point by a scalar (commutative).
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    /// Divides a point by a scalar.
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    /// Adds a point to this point in place.
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    /// Subtracts a point from this point in place.
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    /// Multiplies this point by a scalar in place.
    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    /// Divides this point by a scalar in place.
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
