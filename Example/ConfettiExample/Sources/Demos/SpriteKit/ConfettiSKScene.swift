import ConfettiUI
import Observation
import SpriteKit
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ConfettiSKScene

/// An SKScene that renders confetti particles using SpriteKit nodes.
///
/// This scene demonstrates SpriteKit rendering with ConfettiPlayer:
/// - Uses `ConfettiPlayer` for playback control and state management
/// - Renders particles as `SKSpriteNode` objects
/// - Uses `withObservationTracking` to observe `renderStates` changes
///
/// ## Key Features
///
/// - **Optimized rendering**: Leverages SpriteKit's sprite batching
/// - **Node pooling**: Reuses sprite nodes to minimize allocations
/// - **Automatic updates**: Observation-based synchronization with ConfettiPlayer
///
/// - SeeAlso: ``ConfettiPlayer``
/// - SeeAlso: ``ParticleRenderState``
final class ConfettiSKScene: SKScene {
    // MARK: - Properties

    private let player = ConfettiPlayer()
    private var particleNodes: [SKSpriteNode] = []
    private var isObserving = false

    // MARK: - Initialization

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        startObserving()
    }

    // MARK: - Playback

    func play() {
        player.play(canvasSize: size)
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
            _ = player.simulation.renderStates
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, isObserving else { return }
                updateParticleNodes()
                observeRenderStates()
            }
        }
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        if !isObserving {
            startObserving()
        }
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        stopObserving()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        player.updateCanvasSize(to: size)
    }

    // MARK: - Particle Rendering

    private func updateParticleNodes() {
        let renderStates = player.simulation.renderStates

        // Ensure we have enough nodes (node pooling)
        while particleNodes.count < renderStates.count {
            let node = SKSpriteNode(color: .white, size: CGSize(width: 1, height: 1))
            node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            addChild(node)
            particleNodes.append(node)
        }

        // Update visible nodes
        for (index, state) in renderStates.enumerated() {
            let node = particleNodes[index]
            node.isHidden = false

            // Update position (SpriteKit uses bottom-left origin, flip Y coordinate)
            node.position = CGPoint(x: state.rect.midX, y: size.height - state.rect.midY)

            // Update size
            node.size = state.rect.size

            // Update color
            #if canImport(UIKit)
            node.color = UIColor(cgColor: state.color)
            #elseif canImport(AppKit)
            node.color = NSColor(cgColor: state.color) ?? .white
            #endif
            node.colorBlendFactor = 1.0

            // Update rotation (negate for SpriteKit coordinate system)
            node.zRotation = -state.zRotation

            // Update opacity
            node.alpha = state.opacity
        }

        // Hide unused nodes
        for index in renderStates.count ..< particleNodes.count {
            particleNodes[index].isHidden = true
        }
    }
}
