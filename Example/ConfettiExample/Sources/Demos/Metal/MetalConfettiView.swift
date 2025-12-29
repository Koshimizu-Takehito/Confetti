import ConfettiPlayback
import MetalKit
import SwiftUI

// MARK: - MetalConfettiView

/// A SwiftUI view that renders confetti particles using Metal.
///
/// This view wraps an `MTKView` and uses the `MetalConfettiCoordinator`
/// to render particles with GPU acceleration.
///
/// ## Example
///
/// ```swift
/// MetalConfettiView(renderStates: player.renderStates)
/// ```
struct MetalConfettiView: PlatformAgnosticViewRepresentable {
    // MARK: - Properties

    /// The particle render states to display.
    private let renderStates: [ParticleRenderState]

    // MARK: - Initialization

    /// Creates a Metal confetti view with the given render states.
    /// - Parameter renderStates: The particle states to render.
    init(renderStates: [ParticleRenderState]) {
        self.renderStates = renderStates
    }

    // MARK: - PlatformAgnosticViewRepresentable

    func makePlatformView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: context.coordinator?.device)
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.framebufferOnly = true
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.delegate = context.coordinator

        // Enable transparent background
        #if canImport(UIKit)
        view.isOpaque = false
        view.backgroundColor = .clear
        #elseif canImport(AppKit)
        view.layer?.isOpaque = false
        #endif

        return view
    }

    func updatePlatformView(_: MTKView, context: Context) {
        // Update the coordinator's particle data provider
        context.coordinator?.particleDataProvider = { [renderStates] in
            renderStates.map { state in
                ConfettiParticleData(
                    position: SIMD2<Float>(
                        Float(state.rect.midX),
                        Float(state.rect.midY)
                    ),
                    size: SIMD2<Float>(
                        Float(state.rect.width),
                        Float(state.rect.height)
                    ),
                    color: state.color.simdColor,
                    opacity: Float(state.opacity),
                    zRotation: Float(state.zRotation)
                )
            }
        }
    }

    func makeCoordinator() -> MetalConfettiCoordinator? {
        MetalConfettiCoordinator(device: MTLCreateSystemDefaultDevice())
    }
}

// MARK: - Color Extension

private extension Color {
    /// Converts SwiftUI Color to SIMD4<Float> (RGBA).
    var simdColor: SIMD4<Float> {
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
        // Convert to sRGB color space on macOS
        if let srgbColor = platformColor.usingColorSpace(.sRGB) {
            srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else {
            platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #else
        platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        return SIMD4<Float>(Float(red), Float(green), Float(blue), Float(alpha))
    }
}
