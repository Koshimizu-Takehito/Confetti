import Foundation

// MARK: - Double Utilities

public extension Double {
    /// Linear interpolation from this value to a target value.
    ///
    /// - Parameters:
    ///   - target: The target value to interpolate towards
    ///   - t: Interpolation factor (0.0 = this value, 1.0 = target)
    /// - Returns: The interpolated value
    func lerp(to target: Double, t: Double) -> Double {
        self + (target - self) * t
    }

    /// Clamps this value to a specified range.
    ///
    /// - Parameter range: The range to clamp to
    /// - Returns: The clamped value
    func clamped(to range: ClosedRange<Double>) -> Double {
        max(range.lowerBound, min(range.upperBound, self))
    }
}
