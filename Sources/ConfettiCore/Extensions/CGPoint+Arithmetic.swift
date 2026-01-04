import CoreGraphics

// MARK: - CGPoint Arithmetic Extensions

public extension CGPoint {
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
