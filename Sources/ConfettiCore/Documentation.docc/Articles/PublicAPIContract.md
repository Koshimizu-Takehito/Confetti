# Internal API Contract

This document describes the **internal API contract** for `ConfettiCore` types.

> **Note**: `ConfettiCore` is an **internal module** and is not exposed as a public product.
> Library users should use `ConfettiPlayback` (for `ParticleRenderState` and `ConfettiPlayer`) or `ConfettiUI` (for SwiftUI views).
> Key types like `ConfettiConfig` and `ConfettiColorSource` are re-exported through `ConfettiPlayback`.

This document is intended for **contributors and maintainers** of the Confetti library.

## Goals

- Maintain **internal API stability** with clear rules for contributors.
- Keep simulation **deterministic and testable** via injected randomness.
- Document invariants that `ConfettiPlayback` and `ConfettiUI` depend on.

## Versioning / Compatibility (SemVer)

The Confetti library follows Semantic Versioning:

- **Patch** releases: bug fixes only (no API contract changes).
- **Minor** releases: additive changes only (new APIs, new presets, new docs).
- **Major** releases: breaking changes to the public API contract.

### v2.0.0 Breaking Changes

#### ConfettiSimulation: struct → @Observable class

`ConfettiSimulation` has been changed from a struct to an `@Observable` class:

- **Type change**: `struct` → `@MainActor @Observable public final class`
- **Mutability**: Methods no longer require `mutating` keyword
- **Thread safety**: Must be used from MainActor (enforced by `@MainActor`)
- **State access**: `state` and `configuration` properties are `public private(set)` (read-only from outside)
- **Observable integration**: State changes are automatically tracked by SwiftUI

This change enables:
- Direct observation of simulation state in SwiftUI
- Single Source of Truth (SSoT) architecture in `ConfettiPlayer`
- Elimination of state duplication and synchronization code

#### ParticleRenderState: Color type change

`ParticleRenderState.color` type has been changed to maintain UI-independence:

- **Type change**: `SwiftUI.Color` → `CGColor`
- **Reason**: Keep `ConfettiCore` UI-framework independent
- **Impact**: Canvas rendering requires conversion: `Color(cgColor: state.color)`
- **Module change**: `import SwiftUI` removed from `ParticleRenderState.swift`

Migration example:
```swift
// Before (v1.x)
Canvas { context, _ in
    for state in player.renderStates {
        context.fill(path, with: .color(state.color))  // state.color was SwiftUI.Color
    }
}

// After (v2.0)
Canvas { context, _ in
    for state in player.renderStates {
        context.fill(path, with: .color(Color(cgColor: state.color)))  // Convert CGColor → Color
    }
}
```

#### ConfettiRenderer: struct → class, moved to ConfettiCore

`ConfettiRenderer` has been restructured for better architecture:

- **Type change**: `public struct` → `public final class`
- **Module change**: `ConfettiPlayback` → `ConfettiCore`
- **Sendable removed**: `@MainActor` protection makes `Sendable` conformance unnecessary
- **Mutability**: `mutating` keyword removed from methods (class methods)
- **Re-export**: Still accessible via `ConfettiPlayback` (re-exported from `ConfettiCore`)

Migration example:
```swift
// Before (v1.x)
var renderer = ConfettiRenderer()
let states = renderer.update(from: cloud)  // mutating method

// After (v2.0)
let renderer = ConfettiRenderer()
let states = renderer.update(from: cloud)  // non-mutating method (class)
```

#### renderStates implementation change

Render states remain accessible via `ConfettiPlayer.renderStates`, maintaining API compatibility:

- **API surface**: `player.renderStates` (unchanged from v1.x)
- **Internal architecture**: Computed property forwarding to internal `ConfettiSimulation`
- **Encapsulation**: `ConfettiSimulation` is private, preventing external state manipulation
- **Implementation**: Cached computed property (recomputes only when cloud changes)
- **SSoT benefit**: No manual synchronization needed
- **Performance**: Version-based cache invalidation provides ~180x speedup for repeated access

Migration example:
```swift
// Before (v1.x)
ConfettiCanvas(renderStates: player.renderStates)

// After (v2.0)
ConfettiCanvas(renderStates: player.renderStates)  // Same API, better architecture
```

##### Caching mechanism

`ConfettiSimulation.renderStates` uses an internal cache invalidated by `ConfettiCloud.version`:

- **Cache hit**: Returns cached array when `cloud.version` unchanged (< 0.01ms for 1000 accesses)
- **Cache miss**: Recomputes from `ConfettiRenderer` when cloud mutates
- **Invalidation**: Automatic on `update()`, `seek()`, `withCloudForTesting()`
- **Cleanup**: Cache cleared on `stop()`

This optimization eliminates redundant array allocations in 60fps rendering loops while maintaining SSoT architecture.

## Internal Domain Types

The following types are **internal to ConfettiCore** but have stable contracts that `ConfettiPlayback` depends on:

- ``ConfettiCloud``
- ``ConfettoTraits``
- ``ConfettoState``

They form the *read model* that `ConfettiRenderer` consumes to produce `ParticleRenderState`.

### Stable invariants (guaranteed)

#### ``ConfettiCloud``

- `traits.count == states.count` is always true.
- `0...aliveCount` is always within bounds (i.e. `aliveCount <= traits.count`).
- Alive particles are stored in the prefix range:
  - `traits[0..<aliveCount]`
  - `states[0..<aliveCount]`
- `compact()` removes dead particles by moving them out of the alive prefix and updates `aliveCount`.
- `version` is an integer counter that increments on every mutation:
  - Used for cache invalidation in `ConfettiSimulation.renderStates`
  - Incremented by `incrementVersion()` after any state modification
  - Enables efficient detection of cloud changes without deep equality checks

#### ``ConfettoTraits``

- `id` is stable for the lifetime of a particle and can be used as a renderer identifier.
- `width` / `height` are the **base size** of the particle (before any renderer-specific transforms).
- `color` is provided as `CGColor` to keep `ConfettiCore` UI-framework independent.

#### ``ConfettoState``

- `position` is in the simulation coordinate space where:
  - `x` increases to the right
  - `y` increases downward (CoreGraphics coordinate conventions)
- `velocity` uses the same axis directions as `position`.
- `opacity` is intended to be in the range **0.0...1.0**.

### What is NOT guaranteed (implementation detail)

To keep room for performance and feature evolution, the following are **not** part of the stability contract:

- The *ordering* of particles in `traits` / `states` across frames (it may change due to compaction).
- The exact distribution of random values (it may change if algorithms evolve), except that:
  - With the same configuration, same seed, and same version, results are deterministic.
- The exact physics tuning constants unless explicitly documented as part of `ConfettiConfig`.

## Mutation rules

- `ConfettiSimulation` must be used from `@MainActor` (enforced by the type annotation).
- `ConfettiSimulation.state` is **read-only** from outside; use public methods (`start`, `pause`, `resume`, `seek`, `stop`) to mutate state.
- `ConfettiRenderer` treats `ConfettiCloud` as **read-only** output of the simulation.
- Do not mutate `cloud.states` unless you fully own the simulation loop and accept undefined behavior.
- The `DEBUG`-only API `withCloudForTesting` exists **for tests** and is not meant for production rendering logic.

## Customization points (for library users)

Library users can customize behavior through types re-exported by `ConfettiPlayback`:

- **Physics / behavior**: Customize ``ConfettiConfig`` (or use presets).
- **Colors**: Provide a custom ``ConfettiColorSource`` that outputs `CGColor`.
- **Rendering**: Use `ConfettiPlayback`'s `ParticleRenderState` for custom Canvas/Core Graphics rendering.


