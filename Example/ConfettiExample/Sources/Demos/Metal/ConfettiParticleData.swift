import simd

// MARK: - ConfettiParticleData

/// GPU-compatible particle data structure.
///
/// This struct is used to transfer particle data from CPU to GPU.
/// It must be kept in sync with the corresponding Metal struct in `ConfettiShaders.metal`.
struct ConfettiParticleData {
    /// Position (x, y) in screen coordinates.
    var position: SIMD2<Float>

    /// Size (width, height) after depth scaling.
    var size: SIMD2<Float>

    /// RGBA color.
    var color: SIMD4<Float>

    /// Opacity (0 to 1).
    var opacity: Float

    /// Z-axis rotation in radians.
    var zRotation: Float

    /// Padding for 16-byte alignment (must match Metal struct).
    private var _padding: SIMD2<Float> = .zero

    /// Creates a new particle data instance.
    init(
        position: SIMD2<Float> = .zero,
        size: SIMD2<Float> = .zero,
        color: SIMD4<Float> = .zero,
        opacity: Float = 1.0,
        zRotation: Float = 0
    ) {
        self.position = position
        self.size = size
        self.color = color
        self.opacity = opacity
        self.zRotation = zRotation
    }
}
