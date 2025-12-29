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
for state in player.renderStates {
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
import ConfettiCore
import ConfettiPlayback

struct BrandColors: ConfettiColorSource {
    let palette: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1),
        CGColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1),
    ]
    
    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        palette.randomElement(using: &rng)!
    }
}

let player = ConfettiPlayer(colorSource: BrandColors())
```

## With Metal / SpriteKit

```swift
import ConfettiPlayback

class GameScene: SKScene {
    let player = ConfettiPlayer()
    
    override func update(_ currentTime: TimeInterval) {
        for state in player.renderStates {
            // Convert to your rendering system
            let node = SKShapeNode(rect: state.rect)
            // Example conversion (platform-specific)
            node.fillColor = NSColor(state.color)
            node.alpha = state.opacity
            node.zRotation = state.zRotation
            addChild(node)
        }
    }
}
```

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


