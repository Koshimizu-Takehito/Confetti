import SwiftUI

// MARK: - ConfettiCanvas

/// A pure rendering view that draws confetti particles on a Canvas.
///
/// This view is decoupled from animation logic and simply renders
/// the provided ``ParticleRenderState`` array. Use this when you want
/// full control over how the confetti is driven and displayed.
///
/// ## Example
///
/// ```swift
/// ConfettiCanvas(renderStates: player.renderStates)
/// ```
public struct ConfettiCanvas: View {
    // MARK: - Properties

    private let renderStates: [ParticleRenderState]

    // MARK: - Initializer

    /// Creates a canvas that renders the given particle states.
    /// - Parameter renderStates: Array of particle states to draw
    public init(renderStates: [ParticleRenderState]) {
        self.renderStates = renderStates
    }

    // MARK: - Body

    public var body: some View {
        Canvas { context, _ in
            for state in renderStates {
                context.opacity = state.opacity
                context.fill(particlePath(for: state), with: .color(state.color))
            }
        }
    }

    // MARK: - Private

    private func particlePath(for state: ParticleRenderState) -> Path {
        let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
        return Path(state.rect).applying(
            CGAffineTransform
                .identity
                .translatedBy(x: center.x, y: center.y)
                .rotated(by: state.zRotation)
                .translatedBy(x: -center.x, y: -center.y)
        )
    }
}
