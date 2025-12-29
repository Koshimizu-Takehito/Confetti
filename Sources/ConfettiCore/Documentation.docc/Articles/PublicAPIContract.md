# Public API Contract

This document describes the **stability contract** for `ConfettiCore` public types.

`ConfettiCore` is designed to be useful on its own (without importing `ConfettiPlayback` / `ConfettiUI`), so several domain types are intentionally **public** for custom renderers.

## Goals

- Enable **custom rendering** by reading simulation output (e.g. Metal, SpriteKit, custom engines).
- Keep simulation **deterministic and testable** via injected randomness.
- Maintain **API stability** with clear rules, even when internal implementation evolves.

## Versioning / Compatibility (SemVer)

`ConfettiCore` follows Semantic Versioning:

- **Patch** releases: bug fixes only (no API contract changes).
- **Minor** releases: additive changes only (new APIs, new presets, new docs).
- **Major** releases: breaking changes to the public API contract.

## What is considered “stable” in the Domain API

The following types are **public by design**:

- ``ConfettiCloud``
- ``ConfettoTraits``
- ``ConfettoState``

They form the *read model* that custom renderers can consume.

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

## Mutation rules (how to use safely)

- Custom renderers should treat `ConfettiCloud` as **read-only** output of the simulation.
- Do not mutate `cloud.states` unless you fully own the simulation loop and accept undefined behavior.
- The `DEBUG`-only API `withCloudForTesting` exists **for tests** and is not meant for production rendering logic.

## Where to put customization

- **Physics / behavior**: Customize ``ConfettiConfig`` (or add presets).
- **Colors**: Provide a custom ``ConfettiColorSource`` that outputs `CGColor`.
- **Rendering**: Read `ConfettiCloud` (Core-only), or use `ConfettiPlayback`’s `ParticleRenderState` if you prefer a ready-to-draw representation.


