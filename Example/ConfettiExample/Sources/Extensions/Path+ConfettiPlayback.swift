import ConfettiPlayback
import SwiftUI

extension Path {
    /// Creates a rotated path for rendering a single particle.
    ///
    /// - Parameter state: The render state containing position, size, and rotation.
    /// - Returns: A `Path` representing the rotated particle rectangle.
    init(state: ParticleRenderState) {
        let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
        self = Path(state.rect).applying(
            CGAffineTransform
                .identity
                .translatedBy(x: center.x, y: center.y)
                .rotated(by: state.zRotation)
                .translatedBy(x: -center.x, y: -center.y)
        )
    }
}
