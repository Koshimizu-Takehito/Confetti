# Confetti

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKoshimizu-Takehito%2FConfetti%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Koshimizu-Takehito/Confetti) 
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKoshimizu-Takehito%2FConfetti%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Koshimizu-Takehito/Confetti) 
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/Confetti)

[🇯🇵 日本語](./README.ja.md)

**Confetti** is a Swift package that provides beautiful confetti animations for SwiftUI.

```swift
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```

## Features

- 🎉 Beautiful confetti particle animations
- 🎨 Customizable colors and configuration presets
- ⚡ Smooth 60/120Hz animations with fixed time step simulation
- ▶️ Video-player-like controls (play, pause, resume, seek)
- 🧪 Testable architecture with injectable randomness
- 📦 Modular design (ConfettiCore / ConfettiPlayback / ConfettiUI)

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Example Project](#example-project)
- [Usage](#usage)
- [Architecture](#architecture)
- [Development](#development)
- [License](#license)

## Requirements

- Swift 6.0+
- iOS 18.0+ / macOS 15.0+

---

## Installation

### Swift Package Manager

Add **Confetti** as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Koshimizu-Takehito/Confetti.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ConfettiUI", package: "Confetti")
    ]
)
```

### Xcode

1. File → Add Package Dependencies...
2. Enter: `https://github.com/Koshimizu-Takehito/Confetti.git`
3. Select version: `1.0.0` or later

---

## Example Project

A complete example app is included in the `Example/` directory. It demonstrates all features of Confetti including different integration patterns and runs on both iOS and macOS.

### Running the Example

```bash
# Using xed
xed Example

# Or using make
make open-example
```

Then build and run in Xcode.

### Demo Categories

The example app is organized into three tabs:

#### Platform Tab

Demonstrates integration with various rendering technologies:

| Demo | Description |
|------|-------------|
| **@Observable** | Modern macro-based observation (iOS 17+) |
| **ObservableObject** | Combine-based observation |
| **UIKit/AppKit** | Core Graphics drawing |
| **SpriteKit** | Scene graph based sprite rendering |
| **Metal** | Custom Metal shaders with instanced drawing |

#### Basic Tab

Covers fundamental usage patterns from this README:

| Demo | Description |
|------|-------------|
| **Minimal Usage** | Single-line ConfettiScreen |
| **Full Playback Controls** | ConfettiPlayerScreen with all controls |
| **Custom Trigger Button** | Build your own trigger UI |
| **Button Style** | Customize the default button |
| **Configuration Presets** | celebration, subtle, explosion, snowfall |
| **Custom Configuration** | Fine-tune animation parameters |

#### Advanced Tab

Explores advanced customization patterns:

| Demo | Description |
|------|-------------|
| **Custom Colors** | Brand color integration |
| **Config Presets Gallery** | Interactive preset comparison |
| **Button Styles** | Trigger button variations |
| **Custom Triggers** | Icon, FAB, tap anywhere, long press |
| **Design Tokens** | Compact, regular, large sizing |
| **Advanced Playback** | External control with ConfettiCanvas |

---

## Usage

### Basic Usage

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```

### Custom Trigger Button

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen { canvasSize, play in
            Button("Celebrate! 🎉") {
                play()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### Button Style Customization

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
            .confettiTriggerButtonStyle(.init(
                text: "Party! 🎊",
                gradientColors: [.purple, .pink]
            ))
    }
}
```

### Configuration Presets

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    // Use different presets for different effects
    @State private var player = ConfettiPlayer(configuration: .explosion)
    
    var body: some View {
        ConfettiScreen(player)
    }
}

// Available presets:
// - .celebration (default) - Balanced and festive
// - .subtle                - Gentle and elegant
// - .explosion             - Maximum impact
// - .snowfall              - Gentle falling effect
```

### Custom Configuration

Fine-tune the animation by modifying specific properties through nested configuration structs:

```swift
import ConfettiUI

var config = ConfettiConfig()

// Lifecycle: particle count, duration, fade-out
config.lifecycle.particleCount = 200
config.lifecycle.duration = 5.0
config.lifecycle.fadeOutDuration = 1.5

// Physics: gravity, drag, terminal velocity
config.physics.gravity = 1500
config.physics.drag = 0.92

// Spawn: origin, velocity, angle
config.spawn.originHeightRatio = 0.5
config.spawn.speedRange = 2000...4500

// Appearance: size, rotation
config.appearance.baseSizeRange = 10...18
config.appearance.rotationXSpeedRange = 2.0...6.0

// Wind: force, variation
config.wind.forceRange = -100...100

let player = ConfettiPlayer(configuration: config)
```

### Full Playback Controls

Use `ConfettiPlayerScreen` for a complete video-player-like experience:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiPlayerScreenWithDefaultPlayer()
    }
}
```

### Advanced Playback Control

For external control, use `ConfettiCanvas` directly with `onGeometryChange`:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    @State private var player = ConfettiPlayer()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        VStack {
            ConfettiCanvas(renderStates: player.renderStates)
                .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                    canvasSize = size
                    player.updateCanvasSize(to: size)
                }

            HStack {
                Button("Play") { player.play(canvasSize: canvasSize) }
                Button("Pause") { player.pause() }
                Button("Resume") { player.resume() }
                Button("Seek to 1s") { player.seek(to: 1.0) }
                Button("Stop") { player.stop() }
            }

            Text("Time: \(player.currentTime, specifier: "%.2f") / \(player.duration, specifier: "%.1f")s")
        }
    }
}
```

### Custom Colors

```swift
import ConfettiUI

struct BrandColorSource: ConfettiColorSource {
    let colors: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
        CGColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1),
    ]
    
    mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &numberGenerator)!
    }
}

// Usage
let player = ConfettiPlayer(colorSource: BrandColorSource())
```

### UIKit Integration

Use `ConfettiPlayer` with Core Graphics drawing in a custom `UIView`:

```swift
import ConfettiPlayback
import SwiftUI  // Required for Color.cgColor
import UIKit

class ConfettiView: UIView {
    private let player = ConfettiPlayer()
    private var displayLink: CADisplayLink?
    
    func play() {
        player.play(canvasSize: bounds.size)
        
        // Start display link for VSync-synchronized updates
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleDisplayLink() {
        guard player.isRunning else {
            displayLink?.invalidate()
            displayLink = nil
            return
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for state in player.renderStates {
            guard let cgColor = state.color.cgColor else { continue }
            
            context.saveGState()
            context.setAlpha(state.opacity)
            
            // Apply rotation around center
            let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: state.zRotation)
            context.translateBy(x: -center.x, y: -center.y)
            
            context.setFillColor(cgColor)
            context.fill(state.rect)
            context.restoreGState()
        }
    }
}
```

### AppKit Integration

Similarly, use Core Graphics drawing in a custom `NSView`:

```swift
import AppKit
import ConfettiPlayback
import SwiftUI  // Required for Color.cgColor

class ConfettiView: NSView {
    private let player = ConfettiPlayer()
    private var timer: Timer?
    
    override var isFlipped: Bool { true }
    
    func play() {
        player.play(canvasSize: bounds.size)
        
        // Start timer for frame updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/120.0, repeats: true) { [weak self] _ in
            guard self?.player.isRunning == true else {
                self?.timer?.invalidate()
                return
            }
            self?.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        for state in player.renderStates {
            guard let cgColor = state.color.cgColor else { continue }
            
            context.saveGState()
            context.setAlpha(state.opacity)
            
            let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: state.zRotation)
            context.translateBy(x: -center.x, y: -center.y)
            
            context.setFillColor(cgColor)
            context.fill(state.rect)
            context.restoreGState()
        }
    }
}
```

---

## Architecture

Confetti is designed with a clean, testable, three-layer architecture:

```text
ConfettiUI
  - SwiftUI views / Screens / Trigger components / Design tokens
        │
        ▼
ConfettiPlayback
  - Playback control / Frame driving / Render state conversion / Color source
        │
        ▼
ConfettiCore
  - Domain models / Physics simulation / Deterministic & testable
```

`ConfettiCore` is an **internal module** that is not directly accessible to library users.
Use `ConfettiPlayback` for custom rendering with `ParticleRenderState`, or `ConfettiUI` for ready-to-use SwiftUI views.
Key types like `ConfettiConfig` and `ConfettiColorSource` are re-exported through `ConfettiPlayback`.

### ConfettiCore (internal)

UI-independent domain models and physics simulation (implementation details):

- `ConfettiSimulation`: State machine for simulation lifecycle (pause/resume/seek support)
- `ConfettoTraits`: Immutable particle attributes (size, color, rotation speed)
- `ConfettoState`: Mutable particle state (position, velocity, opacity)
- `ConfettiCloud`: Particle collection with efficient compaction
- `ConfettiConfig`: Simulation configuration with presets (re-exported via ConfettiPlayback)

### ConfettiPlayback

Playback control and render state management:

- `ConfettiPlayer`: Controls confetti playback with video-player-like API
- `ConfettiConfig`: Simulation configuration with presets (re-exported from Core)
- `ConfettiColorSource`: Protocol for custom color palettes (re-exported from Core)
- `ConfettiRenderer`: Converts domain state to render state with buffer reuse
- `ParticleRenderState`: Ready-to-draw particle representation
- `DefaultColorSource`: Default 7-color confetti palette
- `DisplayLinkDriver`: Frame updates (CADisplayLink on iOS, 120Hz Timer on macOS) (internal)

### ConfettiUI

SwiftUI views and components:

- `ConfettiScreen`: Preset view component with customizable trigger
- `ConfettiPlayerScreen`: Full-featured player with playback controls
- `ConfettiCanvas`: Canvas-based particle rendering
- `ConfettiTriggerButton`: Stylized trigger button
- `ConfettiDesignTokens`: Customizable design system for UI components

### Design Principles

- **Fixed time step simulation**: Animation speed is consistent across 60Hz and 120Hz displays
- **Deterministic seeking**: Seek to any time and get consistent results
- **Injectable randomness**: Enables deterministic testing
- **Separation of concerns**: Core logic is UI-independent
- **Reusable playback control**: `ConfettiPlayer` can be used with custom views
- **Buffer reuse**: Minimizes allocations during animation

---

## Development

### Requirements

- macOS 15.0+
- Xcode 16.0+ (Swift 6.0+)
- [Mint](https://github.com/yonaskolb/Mint) (installed automatically via `make setup` when Homebrew is available)

### Setup

```bash
# Clone the repository
git clone https://github.com/Koshimizu-Takehito/Confetti.git
cd Confetti

# Install dependencies
make setup
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make setup` | Install Mint (if needed) and dependencies via Mint |
| `make sync` | Pull latest changes and update all dependencies |
| `make build` | Build the package |
| `make test` | Run tests |
| `make lint` | Run SwiftLint |
| `make lint-fix` | Run SwiftLint with auto-correction |
| `make lint-strict` | Run SwiftLint treating warnings as errors |
| `make format` | Format code with SwiftFormat |
| `make format-check` | Check code formatting (CI) |
| `make fix` | Format and auto-fix all code |
| `make ci` | Run all CI checks |
| `make open` | Open package in Xcode |
| `make open-example` | Open example project in Xcode |
| `make clean` | Clean build artifacts |
| `make help` | Show available commands |

### Before Submitting a PR

Run all CI checks locally to ensure your changes pass:

```bash
make ci
```

---

## License

Confetti is available under the MIT License. See the [LICENSE](LICENSE) file for details.
