# Quick Start

Use `ConfettiPlayback` when you need playback control without SwiftUI views.

## Basic Usage with Custom Rendering

```swift
import ConfettiPlayback

// Create a player
let player = ConfettiPlayer()

// Start playback
player.play(canvasSize: CGSize(width: 300, height: 600))

// Access render states for custom rendering
for state in player.simulation.renderStates {
    // state.rect: CGRect - particle bounds
    // state.color: Color - fill color (dynamic)
    // state.opacity: Double - opacity (0-1)
    // state.zRotation: Double - rotation angle
    // Convert to your renderer's color type as needed.
    myRenderer.drawRect(state.rect, color: state.color, opacity: state.opacity)
}

// Playback controls
player.pause()
player.resume()
player.seek(to: 1.5)
player.stop()
```

## Configuration Presets

Use built-in presets for common scenarios:

```swift
// Subtle, elegant effect
let player = ConfettiPlayer(configuration: .subtle)

// Maximum impact
let player = ConfettiPlayer(configuration: .explosion)

// Gentle falling effect
let player = ConfettiPlayer(configuration: .snowfall)
```

## Custom Colors

Inject your own color palette:

```swift
import ConfettiPlayback

struct BrandColors: ConfettiColorSource {
    let palette: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1),
        CGColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1),
    ]
    
    mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor {
        palette.randomElement(using: &numberGenerator)!
    }
}

let player = ConfettiPlayer(colorSource: BrandColors())
```

## With SpriteKit / Metal

For SpriteKit or Metal integration, access `player.simulation.renderStates` and convert to your rendering system:

```swift
import ConfettiPlayback
import SpriteKit

// Conceptual example - see Example project for full implementation
class GameScene: SKScene {
    let player = ConfettiPlayer()
    private var particleNodes: [SKSpriteNode] = []
    
    func play() {
        player.play(canvasSize: size)
    }
    
    func updateParticles() {
        for (index, state) in player.simulation.renderStates.enumerated() {
            // Node pooling: reuse existing nodes or create new ones
            let node = getOrCreateNode(at: index)
            
            // SpriteKit uses bottom-left origin, so flip Y coordinate
            node.position = CGPoint(x: state.rect.midX, y: size.height - state.rect.midY)
            node.size = state.rect.size
            node.alpha = state.opacity
            node.zRotation = -state.zRotation  // Negate for SpriteKit
            // ... set color
        }
    }
}
```

> **Note**: The Example project contains complete implementations for SpriteKit (`ConfettiSKScene`) and Metal (`MetalConfettiCoordinator`) with proper node pooling, observation, and coordinate transformations.

## SwiftUI Users

If you're using SwiftUI, import `ConfettiUI` instead—it re-exports `ConfettiPlayback` and provides ready-to-use views.

```swift
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```


