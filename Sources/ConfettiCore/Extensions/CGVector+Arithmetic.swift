import CoreGraphics

// MARK: - CGVector Arithmetic Extensions

public extension CGVector {
    /// Adds two vectors component-wise.
    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    /// Subtracts two vectors component-wise.
    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    /// Multiplies a vector by a scalar.
    static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
        CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }

    /// Multiplies a vector by a scalar (commutative).
    static func * (lhs: CGFloat, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
    }

    /// Divides a vector by a scalar.
    static func / (lhs: CGVector, rhs: CGFloat) -> CGVector {
        CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }

    /// Adds a vector to this vector in place.
    static func += (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs + rhs
    }

    /// Subtracts a vector from this vector in place.
    static func -= (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs - rhs
    }

    /// Multiplies this vector by a scalar in place.
    static func *= (lhs: inout CGVector, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    /// Divides this vector by a scalar in place.
    static func /= (lhs: inout CGVector, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
