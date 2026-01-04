#if canImport(UIKit)
import ConfettiPlayback
import Observation
import SwiftUI
import UIKit

// MARK: - ConfettiDrawingView

/// A UIView that renders confetti particles using Core Graphics.
///
/// This view demonstrates pure UIKit rendering without SwiftUI:
/// - Uses `ConfettiPlayer` for playback control and state management
/// - Draws particles in `draw(_:)` using `CGContext`
/// - Uses `withObservationTracking` to observe `renderStates` changes
final class ConfettiDrawingView: UIView {
    // MARK: - Properties

    private let player = ConfettiPlayer()

    /// Flag to prevent observation after view is invalidated
    private var isObserving = false

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        startObserving()
    }

    isolated deinit {
        stopObserving()
    }

    // MARK: - Playback

    func play() {
        player.play(canvasSize: bounds.size)
    }

    // MARK: - Observation

    private func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        observeRenderStates()
    }

    private func stopObserving() {
        isObserving = false
    }

    private func observeRenderStates() {
        guard isObserving else { return }

        let player = player

        withObservationTracking {
            _ = player.renderStates
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, isObserving else { return }
                setNeedsDisplay()
                observeRenderStates()
            }
        }
    }

    // MARK: - View Lifecycle

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            stopObserving()
        } else if !isObserving {
            startObserving()
        }
    }

    // MARK: - Drawing

    override func draw(_: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for state in player.renderStates {
            context.saveGState()
            context.setAlpha(state.opacity)

            let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: state.zRotation)
            context.translateBy(x: -center.x, y: -center.y)

            context.setFillColor(state.color)
            context.fill(state.rect)

            context.restoreGState()
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        player.updateCanvasSize(to: bounds.size)
    }
}
#endif
