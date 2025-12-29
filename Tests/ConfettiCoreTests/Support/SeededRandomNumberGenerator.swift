import Foundation

/// Seeded random number generator (LCG) for deterministic testing.
///
/// Always generates the same sequence when initialized with the same seed.
/// - Warning: Not suitable for cryptographic use.
struct SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64

    /// Initializes with the specified seed.
    /// - Parameter seed: Seed value (uses default value if 0)
    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEAD_BEEF_CAFE_BABE : seed
    }

    mutating func next() -> UInt64 {
        state = 6_364_136_223_846_793_005 &* state &+ 1
        return state
    }
}
