import CoreGraphics

// MARK: - CGRect Utilities

public extension CGRect {
    /// Checks if a point is within the rectangle with an additional margin.
    ///
    /// - Parameters:
    ///   - point: The point to check
    ///   - margin: Additional margin around the rectangle (positive expands, negative shrinks)
    /// - Returns: `true` if the point is within the rectangle plus margin
    func contains(_ point: CGPoint, margin: CGFloat) -> Bool {
        let expandedRect = insetBy(dx: -margin, dy: -margin)
        return expandedRect.contains(point)
    }
}
