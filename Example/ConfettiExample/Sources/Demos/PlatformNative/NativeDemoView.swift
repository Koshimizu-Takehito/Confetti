import SwiftUI

// MARK: - NativeDemoView

/// A unified SwiftUI wrapper for presenting platform-native confetti demonstrations.
///
/// This type alias provides a single entry point for both UIKit (iOS/visionOS) and AppKit (macOS)
/// native drawing demos, eliminating the need for platform-specific conditional compilation
/// at the call site.
///
/// ## Usage
///
/// ```swift
/// NavigationLink {
///     NativeDemoView()
///         .navigationTitle(NativeDemoView.navigationTitle)
/// } label: {
///     Text(NativeDemoView.rowTitle)
/// }
/// ```
///
/// ## Platform Support
///
/// - **iOS/visionOS**: Uses ``NativeDemoViewController`` with UIKit
/// - **macOS**: Uses ``NativeDemoViewController`` with AppKit
struct NativeDemoView: PlatformAgnosticViewControllerRepresentable {
    // MARK: - Platform Labels

    #if canImport(UIKit) && !os(macOS)
    static let sectionTitle = "UIKit Integration"
    static let navigationTitle = "UIKit Demo"
    static let rowTitle = "UIKit Demo"
    static let rowSubtitle = "ConfettiPlayer in UIViewController"
    #elseif canImport(AppKit)
    static let sectionTitle = "AppKit Integration"
    static let navigationTitle = "AppKit Demo"
    static let rowTitle = "AppKit Demo"
    static let rowSubtitle = "ConfettiPlayer in NSViewController"
    #endif

    // MARK: - PlatformAgnosticViewControllerRepresentable

    func makePlatformViewController(context _: Context) -> NativeDemoViewController {
        NativeDemoViewController()
    }

    func updatePlatformViewController(_: NativeDemoViewController, context _: Context) {}
}

// MARK: - NativeDemoViewController

/// A demonstration view controller showcasing confetti integration with UIKit/AppKit.
///
/// This view controller demonstrates how to use ``ConfettiPlayer`` in a platform-native
/// application using pure Core Graphics drawing via `UIView.draw(_:)` / `NSView.draw(_:)`.
///
/// ## Overview
///
/// This demo shows that `ConfettiPlayer` can be used with native drawing
/// mechanism without embedding SwiftUI views:
///
/// 1. Create a ``ConfettiPlayer`` instance
/// 2. Use `withObservationTracking` to observe `renderStates` changes
/// 3. Draw particles using Core Graphics in `draw(_:)`
///
/// ## Key Features
///
/// - **Pure native rendering**: No SwiftUI views or Hosting Controller
/// - **Core Graphics drawing**: Uses `CGContext` for efficient particle rendering
/// - **Observation-based updates**: Leverages `@Observable` for automatic redraw
/// - **Interface Builder integration**: UI layout configured via XIB
///
/// - SeeAlso: ``ConfettiPlayer``
/// - SeeAlso: ``ParticleRenderState``
final class NativeDemoViewController: PlatformViewController {
    // MARK: - IBOutlets

    @IBOutlet private var confettiView: ConfettiDrawingView!

    // MARK: - IBActions

    @IBAction
    private func triggerConfetti(_: Any) {
        confettiView.play()
    }
}

// MARK: - Preview

#Preview {
    NativeDemoView()
}
