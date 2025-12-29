# Quick Start

## Minimal Example: Drop-in View

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```

## Configuration Presets

Use built-in presets for different effects:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    // Subtle, elegant effect
    @State private var player = ConfettiPlayer(configuration: .subtle)
    
    var body: some View {
        ConfettiScreen(player)
    }
}
```

Available presets:
- `.celebration` - Standard festive effect (default)
- `.subtle` - Gentle and elegant
- `.explosion` - Maximum impact
- `.snowfall` - Gentle falling effect

## Custom Colors

Inject your own color palette:

```swift
import SwiftUI
import ConfettiUI

struct BrandColors: ConfettiColorSource {
    let palette: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1),
        CGColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1),
    ]
    
    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        palette.randomElement(using: &rng)!
    }
}

struct ContentView: View {
    @State private var player = ConfettiPlayer(colorSource: BrandColors())
    
    var body: some View {
        ConfettiScreen(player)
    }
}
```

## Example: External Player Control

For external control, use `ConfettiCanvas` directly with `GeometryReader`:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    @State private var player = ConfettiPlayer()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ConfettiCanvas(renderStates: player.renderStates)
                    .onAppear { canvasSize = geometry.size }
                    .onChange(of: geometry.size) { _, size in canvasSize = size }
            }

            HStack {
                Button("Play") { player.play(canvasSize: canvasSize) }
                Button("Pause") { player.pause() }
                Button("Resume") { player.resume() }
                Button("Seek 1s") { player.seek(to: 1.0) }
                Button("Stop") { player.stop() }
            }
        }
    }
}
```

