import CoreGraphics
import simd

// MARK: - RGBAComponents

/// RGBA color components.
struct RGBAComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

// MARK: - CGColor Extension

extension CGColor {
    /// Converts CGColor to SIMD4<Float> (RGBA) for Metal rendering.
    var simdColor: SIMD4<Float> {
        let components = extractComponents()
        return SIMD4<Float>(
            Float(components.red),
            Float(components.green),
            Float(components.blue),
            Float(components.alpha)
        )
    }

    /// Extracts RGBA components from the color for shader effects.
    var rgbaComponents: RGBAComponents {
        extractComponents()
    }

    // MARK: - Private Helpers

    /// Extracts RGBA components from CGColor, handling various color spaces.
    private func extractComponents() -> RGBAComponents {
        guard let components else {
            #if DEBUG
            assertionFailure("Failed to extract CGColor components")
            #endif
            // Fallback to black if components cannot be extracted
            return RGBAComponents(red: 0, green: 0, blue: 0, alpha: 1)
        }

        let numberOfComponents = numberOfComponents

        if numberOfComponents == 4 {
            // RGBA color space
            return RGBAComponents(
                red: components[0],
                green: components[1],
                blue: components[2],
                alpha: components[3]
            )
        } else if numberOfComponents == 2 {
            // Grayscale with alpha
            let gray = components[0]
            return RGBAComponents(red: gray, green: gray, blue: gray, alpha: components[1])
        } else if numberOfComponents == 1 {
            // Grayscale without alpha
            let gray = components[0]
            return RGBAComponents(red: gray, green: gray, blue: gray, alpha: 1.0)
        } else if numberOfComponents >= 3 {
            // RGB without alpha (or more components)
            return RGBAComponents(
                red: components[0],
                green: components[1],
                blue: components[2],
                alpha: 1.0
            )
        } else {
            #if DEBUG
            assertionFailure("Unexpected number of color components: \(numberOfComponents)")
            #endif
            // Fallback
            return RGBAComponents(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
