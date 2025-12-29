import SpriteKit
import SwiftUI

// MARK: - SpriteKitDemoView

struct SpriteKitDemoView: PlatformAgnosticViewControllerRepresentable {
    func makePlatformViewController(context _: Context) -> SpriteKitDemoViewController {
        SpriteKitDemoViewController()
    }

    func updatePlatformViewController(_: SpriteKitDemoViewController, context _: Context) {}
}

// MARK: - SpriteKitDemoViewController

/// A demonstration view controller showcasing confetti integration with SpriteKit.
///
/// This view controller demonstrates how to use ``ConfettiPlayer`` in a SpriteKit-based
/// application using `SKSpriteNode` for particle rendering.
///
/// ## Overview
///
/// This demo shows that `ConfettiPlayer` can be used with SpriteKit's scene graph:
///
/// 1. Create a ``ConfettiPlayer`` instance in an `SKScene`
/// 2. Use `withObservationTracking` to observe `renderStates` changes
/// 3. Render particles as `SKSpriteNode` objects
///
/// ## Key Features
///
/// - **SpriteKit rendering**: Uses GPU-accelerated sprite rendering
/// - **Scene graph management**: Efficient node pooling and reuse
/// - **Observation-based updates**: Leverages `@Observable` for automatic scene updates
/// - **Interface Builder integration**: UI layout configured via XIB
///
/// - SeeAlso: ``ConfettiPlayer``
/// - SeeAlso: ``ParticleRenderState``
final class SpriteKitDemoViewController: PlatformViewController {
    // MARK: - IBOutlets

    @IBOutlet private var skView: SKView!

    // MARK: - Properties

    private lazy var confettiScene = ConfettiSKScene(size: skView.bounds.size)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        skView.allowsTransparency = true
    }

    #if canImport(UIKit)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presentSceneIfNeeded()
    }

    #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
    override func viewDidLayout() {
        super.viewDidLayout()
        presentSceneIfNeeded()
    }
    #endif

    private func presentSceneIfNeeded() {
        if skView.scene == nil {
            confettiScene.scaleMode = .resizeFill
            confettiScene.backgroundColor = .clear
            skView.presentScene(confettiScene)
        }
    }

    // MARK: - IBActions

    @IBAction
    private func triggerConfetti(_: Any) {
        confettiScene.play()
    }
}

#Preview {
    SpriteKitDemoView()
}
