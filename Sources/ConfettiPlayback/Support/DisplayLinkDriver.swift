#if canImport(UIKit)
import QuartzCore
import UIKit

/// Driver that emits callbacks synchronized with screen refresh.
///
/// Uses `CADisplayLink` on iOS to provide VSync-synchronized frame updates.
@MainActor
final class DisplayLinkDriver {
    // MARK: - Properties

    private var displayLink: CADisplayLink?
    private var handler: ((Date) -> Void)?

    // MARK: - Public API

    /// Sets the callback for frame updates and starts.
    /// - Parameter handler: Closure called each frame
    func start(handler: @escaping (Date) -> Void) {
        stop()
        self.handler = handler

        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    /// Stops DisplayLink and releases resources.
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        handler = nil
    }

    // MARK: - Private

    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        // Use CADisplayLink's monotonic timestamp instead of Date.now to avoid jitter and
        // to correctly reflect display refresh cadence.
        handler?(Date(timeIntervalSinceReferenceDate: displayLink.timestamp))
    }
}

#elseif canImport(AppKit)
import Foundation

/// Driver that emits callbacks synchronized with screen refresh.
///
/// Uses a high-precision Timer (120Hz) on macOS as `CVDisplayLink` is deprecated.
@MainActor
final class DisplayLinkDriver {
    // MARK: - Properties

    private var timer: Timer?
    private var handler: ((Date) -> Void)?
    private static let frameInterval: TimeInterval = 1.0 / 120.0

    // MARK: - Public API

    /// Sets the callback for frame updates and starts.
    /// - Parameter handler: Closure called each frame
    func start(handler: @escaping (Date) -> Void) {
        stop()
        self.handler = handler

        let timer = Timer(timeInterval: Self.frameInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // Use a monotonic-ish time source to avoid jumps when system clock changes.
                // We mirror the iOS path which uses a display-link timestamp (not wall-clock).
                let uptime = ProcessInfo.processInfo.systemUptime
                self?.handler?(Date(timeIntervalSinceReferenceDate: uptime))
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Stops Timer and releases resources.
    func stop() {
        timer?.invalidate()
        timer = nil
        handler = nil
    }
}
#endif
