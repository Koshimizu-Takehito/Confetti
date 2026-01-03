import ConfettiPlayback
import MetalKit
import SwiftUI

// MARK: - MetalConfettiView

/// A SwiftUI view that renders confetti particles using Metal.
///
/// This view wraps an `MTKView` and uses the `MetalConfettiCoordinator`
/// to render particles using custom Metal shaders.
///
/// ## Example
///
/// ```swift
/// MetalConfettiView(renderStates: player.simulation.renderStates)
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
