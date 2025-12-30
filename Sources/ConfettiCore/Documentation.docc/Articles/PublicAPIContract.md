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

- `ConfettiRenderer` treats `ConfettiCloud` as **read-only** output of the simulation.
- Do not mutate `cloud.states` unless you fully own the simulation loop and accept undefined behavior.
- The `DEBUG`-only API `withCloudForTesting` exists **for tests** and is not meant for production rendering logic.

## Customization points (for library users)

Library users can customize behavior through types re-exported by `ConfettiPlayback`:

- **Physics / behavior**: Customize ``ConfettiConfig`` (or use presets).
- **Colors**: Provide a custom ``ConfettiColorSource`` that outputs `CGColor`.
- **Rendering**: Use `ConfettiPlayback`'s `ParticleRenderState` for custom Canvas/Core Graphics rendering.


