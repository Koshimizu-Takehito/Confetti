#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import ConfettiPlayback
import Observation
import SwiftUI

// MARK: - ConfettiDrawingView

/// An NSView that renders confetti particles using Core Graphics.
///
/// This view demonstrates pure AppKit rendering without SwiftUI:
/// - Uses `ConfettiPlayer` for playback control and state management
/// - Draws particles in `draw(_:)` using `CGContext`
/// - Uses `withObservationTracking` to observe `renderStates` changes
final class ConfettiDrawingView: NSView {
    // MARK: - Properties

    private let player = ConfettiPlayer()

    /// Flag to prevent observation after view is invalidated
    private var isObserving = false

    // MARK: - Initializers

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        startObserving()
    }

    isolated deinit {
        stopObserving()
    }

    // MARK: - Flipped Coordinate System

    override var isFlipped: Bool { true }

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
                needsDisplay = true
                observeRenderStates()
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            stopObserving()
        } else if !isObserving {
            startObserving()
        }
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.clear(dirtyRect)

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

    override func layout() {
        super.layout()
        player.updateCanvasSize(to: bounds.size)
    }
}
#endif
