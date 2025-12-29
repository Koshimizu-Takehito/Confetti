import CoreGraphics

/// Protocol that supplies colors for particles.
///
/// The Core module does not depend on concrete UI colors and obtains colors through this protocol.
/// Implementations can return any `CGColor`, enabling full customization of the confetti palette.
///
/// ## Example: Custom Color Source
///
/// ```swift
/// struct MyColorSource: ConfettiColorSource {
///     let colors: [CGColor] = [
///         CGColor(red: 1, green: 0, blue: 0, alpha: 1),
///         CGColor(red: 0, green: 1, blue: 0, alpha: 1),
///     ]
///
///     mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
///         colors.randomElement(using: &rng)!
///     }
/// }
/// ```
public protocol ConfettiColorSource: Sendable {
    /// Returns the next particle color.
    /// - Parameter numberGenerator: Random number generator to use
    /// - Returns: A `CGColor` representing the particle's fill color
    mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor
}
