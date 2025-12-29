# Quick Start

`ConfettiCore` provides the simulation engine only. For rendering, use ``ConfettiCanvas`` from `ConfettiUI`.

## Architecture (Core / Playback / UI)

```text
ConfettiUI
  - SwiftUI views / Canvas rendering / Screens / Trigger
        │
        ▼
ConfettiPlayback
  - Playback control / Frame driving / Render state conversion
        │
        ▼
ConfettiCore
  - Domain models / Physics simulation / Deterministic & testable
```

## Minimal Example: start → tick

`ConfettiSimulation` advances time using a **fixed time step**. Call `tick` at your display refresh rate.

```swift
import ConfettiCore
import CoreGraphics

// Custom color source returning CGColor
struct MyColorSource: ConfettiColorSource {
    let colors: [CGColor] = [
        CGColor(red: 1, green: 0.4, blue: 0.4, alpha: 1),
        CGColor(red: 0.4, green: 0.8, blue: 1, alpha: 1),
    ]
    mutating func nextColor(using rng: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &rng)!
    }
}

var config = ConfettiConfig()
config.particleCount = 150

var simulation = ConfettiSimulation(configuration: config)
var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()

simulation.start(
    bounds: CGSize(width: 300, height: 600),
    at: .now,
    colorSource: MyColorSource(),
    using: &rng
)

simulation.tick(at: .now, bounds: CGSize(width: 300, height: 600))
```

## Deterministic Testing

- Inject a `RandomNumberGenerator` to get reproducible results with the same seed.
- See `Tests/ConfettiCoreTests/ConfettiSimulationTests.swift` for examples.

## API Stability

If you build a custom renderer by importing `ConfettiCore` only, see <doc:PublicAPIContract> for the stability contract of `ConfettiCloud` and related domain types.


