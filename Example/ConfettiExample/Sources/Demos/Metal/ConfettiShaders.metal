#include <metal_stdlib>
using namespace metal;

// MARK: - Data Structures

/// GPU-compatible particle data structure.
/// Must be kept in sync with the Swift ConfettiParticleData struct.
struct ConfettiParticleData {
    float2 position;
    float2 size;
    float4 color;
    float opacity;
    float zRotation;
    float2 _padding;
};

/// Vertex shader output / Fragment shader input.
struct VertexOut {
    float4 position [[position]];
    float4 color;
    float opacity;
};

// MARK: - Vertex Shader

/// Vertex shader for confetti particle rendering using instanced quads.
///
/// Each particle is rendered as a quad (2 triangles, 6 vertices).
/// The shader applies rotation and converts to normalized device coordinates.
///
/// - Parameters:
///   - vertexID: Vertex index within the quad (0-5)
///   - instanceID: Particle index
///   - particles: Array of particle data
///   - viewportSize: Viewport dimensions for coordinate conversion
vertex VertexOut confettiVertexShader(
    uint vertexID [[vertex_id]],
    uint instanceID [[instance_id]],
    constant ConfettiParticleData* particles [[buffer(0)]],
    constant float2& viewportSize [[buffer(1)]]
) {
    ConfettiParticleData particle = particles[instanceID];

    // 6 vertices per quad (2 triangles)
    // 0--1    Triangle 1: 0, 1, 2
    // |\ |    Triangle 2: 2, 1, 3
    // 2--3
    float2 corners[6] = {
        float2(-0.5, -0.5), // 0 (top-left)
        float2( 0.5, -0.5), // 1 (top-right)
        float2(-0.5,  0.5), // 2 (bottom-left)
        float2(-0.5,  0.5), // 2 (bottom-left)
        float2( 0.5, -0.5), // 1 (top-right)
        float2( 0.5,  0.5)  // 3 (bottom-right)
    };

    float2 corner = corners[vertexID];

    // Apply Z-axis rotation
    float cosZ = cos(particle.zRotation);
    float sinZ = sin(particle.zRotation);
    float2 rotated = float2(
        corner.x * cosZ - corner.y * sinZ,
        corner.x * sinZ + corner.y * cosZ
    );

    // Scale by particle size
    float2 scaled = rotated * particle.size;

    // Translate to particle position
    float2 worldPos = particle.position + scaled;

    // Convert to normalized device coordinates (-1 to 1)
    float2 ndc = (worldPos / viewportSize) * 2.0 - 1.0;
    ndc.y = -ndc.y; // Flip Y for Metal coordinate system (origin at top-left)

    VertexOut out;
    out.position = float4(ndc, 0.0, 1.0);
    out.color = particle.color;
    out.opacity = particle.opacity;
    return out;
}

// MARK: - Fragment Shader

/// Fragment shader for confetti particle rendering.
///
/// Simply outputs the interpolated color with opacity applied.
fragment float4 confettiFragmentShader(VertexOut in [[stage_in]]) {
    return float4(in.color.rgb, in.color.a * in.opacity);
}

