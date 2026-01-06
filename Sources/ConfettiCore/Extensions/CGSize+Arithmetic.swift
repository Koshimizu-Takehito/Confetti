import CoreGraphics

// MARK: - CGSize Arithmetic Extensions

public extension CGSize {
    // MARK: - Initialization

    /// Creates a size with the same scalar value for both width and height.
    init(scalar: CGFloat) {
        self.init(width: scalar, height: scalar)
    }

    // MARK: - Arithmetic Operators

    /// Multiplies a size by a scalar.
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    /// Multiplies a size by a scalar (commutative).
    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }

    /// Divides a size by a scalar.
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    /// Multiplies this size by a scalar in place.
    static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    /// Divides this size by a scalar in place.
    static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
