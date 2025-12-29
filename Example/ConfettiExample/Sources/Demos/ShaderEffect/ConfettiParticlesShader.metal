#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// MARK: - Confetti Particles Shader

namespace ConfettiParticles {
    /// Renders confetti particles using SwiftUI's layerEffect.
    ///
    /// Each particle is encoded as 10 floats:
    /// - [0-1]: position (x, y)
    /// - [2-3]: size (width, height)
    /// - [4-7]: color (r, g, b, a)
    /// - [8]: opacity
    /// - [9]: zRotation (radians)
    ///
    /// The shader samples the background layer and composites particles on top.
    ///
    /// - Parameters:
    ///   - position: The current pixel position on the layer.
    ///   - layer: The SwiftUI layer to be sampled (background).
    ///   - bounds: The bounding rect of the layer.
    ///   - particles: Array of particle data (10 floats per particle).
    ///   - particleCount: Number of particles in the array.
    /// - Returns: The composited color (background + particles).
    [[ stitchable ]] half4 main(
        float2 position,
        SwiftUI::Layer layer,
        float4 bounds,
        device const float* particles,
        int particleCount
    ) {
        // Sample background layer
        half4 background = layer.sample(position);
        
        // particleCount is the total number of floats, divide by 10 to get particle count
        int count = particleCount / 10;
        // Iterate through particles (back to front for proper alpha blending)
        for (int i = 0; i < count; i++) {
            int idx = i * 10;
            // Decode particle data
            float2 center = float2(particles[idx], particles[idx + 1]);
            float2 size = float2(particles[idx + 2], particles[idx + 3]);
            half4 color = half4(particles[idx + 4], particles[idx + 5], particles[idx + 6], particles[idx + 7]);
            float opacity = particles[idx + 8];
            float zRotation = particles[idx + 9];
            
            // Transform position relative to particle center
            float2 diff = position - center;
            
            // Apply inverse rotation to check if point is inside rotated rectangle
            float cosZ = cos(-zRotation);
            float sinZ = sin(-zRotation);
            float2 rotated = float2(diff.x * cosZ - diff.y * sinZ, diff.x * sinZ + diff.y * cosZ);
            
            // Check if inside rectangle bounds
            float halfWidth = size.x / 2.0;
            float halfHeight = size.y / 2.0;
            
            if (abs(rotated.x) <= halfWidth && abs(rotated.y) <= halfHeight) {
                // Alpha blend particle onto background
                half alpha = color.a * half(opacity);
                background = mix(background, half4(color.rgb, 1.0), alpha);
            }
        }

        half4 sample = layer.sample(position);
        if (background.r != sample.r || background.g != sample.g || background.b != sample.b || background.a != sample.a) {
            return background;
        } else {
            return sample;
        }
    }
}

