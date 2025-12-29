import ConfettiPlayback
import SwiftUI

// MARK: - ShaderEffectDemoView

/// A demonstration view showcasing confetti rendering using SwiftUI's layerEffect.
///
/// This view demonstrates how to use Metal shaders with SwiftUI's native
/// shader integration, providing an alternative to MTKView-based rendering.
///
/// ## Overview
///
/// The view uses `ConfettiPlayer` from ConfettiPlayback and renders particles
/// using a custom Metal shader applied via `.layerEffect()`.
///
/// ## Key Features
///
/// - **SwiftUI native**: Uses `.layerEffect()` modifier
/// - **No MTKView**: Pure SwiftUI integration
/// - **Data-driven**: Particle data passed via `.floatArray()`
/// - **Background compositing**: Particles are blended on top of background
///
/// ## Example Usage
///
/// ```swift
/// NavigationLink {
///     ShaderEffectDemoView()
/// } label: {
///     Text("ShaderEffect Demo")
/// }
/// ```
struct ShaderEffectDemoView: View {
    // MARK: - Properties

    /// The view model managing confetti playback state.
    @State private var viewModel = ShaderEffectDemoViewModel()

    // MARK: - Body

    var body: some View {
        Rectangle()
            .foregroundStyle(.background)
            .layerEffect(confettiShader, maxSampleOffset: .zero)
            .overlay(alignment: .bottom) {
                DemoTriggerButton(.cyan, .blue) {
                    viewModel.fire()
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            }
            .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                viewModel.canvasSize = size
            }
            .onDisappear {
                viewModel.stop()
            }
    }

    // MARK: - Shader

    /// The confetti particles shader with current particle data.
    private var confettiShader: Shader {
        let particleData = viewModel.renderStates.shaderData
        let function = ShaderFunction(library: .default, name: "ConfettiParticles::main")
        return function(.boundingRect, .floatArray(particleData))
    }
}

// MARK: - ParticleRenderState Extension

private extension [ParticleRenderState] {
    /// Encodes the particle render states as a float array for the shader.
    ///
    /// Each particle is encoded as 10 floats:
    /// - [0-1]: position (x, y)
    /// - [2-3]: size (width, height)
    /// - [4-7]: color (r, g, b, a)
    /// - [8]: opacity
    /// - [9]: zRotation (radians)
    var shaderData: [Float] {
        flatMap { state -> [Float] in
            let rgba = state.color.rgbaComponents
            return [
                Float(state.rect.midX),
                Float(state.rect.midY),
                Float(state.rect.width),
                Float(state.rect.height),
                Float(rgba.red),
                Float(rgba.green),
                Float(rgba.blue),
                Float(rgba.alpha),
                Float(state.opacity),
                Float(state.zRotation),
            ]
        }
    }
}

// MARK: - RGBAComponents

/// RGBA color components.
private struct RGBAComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

// MARK: - Color Extension

private extension Color {
    /// Extracts RGBA components from the color.
    var rgbaComponents: RGBAComponents {
        #if canImport(UIKit)
        let platformColor = UIColor(self)
        #elseif canImport(AppKit)
        let platformColor = NSColor(self)
        #endif

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        if let srgbColor = platformColor.usingColorSpace(.sRGB) {
            srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else {
            platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #else
        platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Previews

#Preview {
    ShaderEffectDemoView()
}
