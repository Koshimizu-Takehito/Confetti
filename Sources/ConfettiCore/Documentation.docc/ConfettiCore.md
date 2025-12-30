# ``ConfettiCore``

An internal module that provides UI-independent confetti simulation.

> **Note**: `ConfettiCore` is an **internal module** and is not exposed as a public product.
> Library users should use `ConfettiPlayback` or `ConfettiUI` instead.
> Key types like `ConfettiConfig` and `ConfettiColorSource` are re-exported through `ConfettiPlayback`.

`ConfettiCore` handles **physics simulation** and **domain models** without depending on UI frameworks like SwiftUI.

## Overview

`ConfettiCore` provides a deterministic, fixed-time-step simulation engine for confetti particles. It's designed to be testable and reusable across different UI frameworks.

## Getting Started

- ``ConfettiSimulation``: The simulation engine (start/tick/pause/resume/seek/stop)
- ``ConfettiConfig``: Configuration for particle count, gravity, wind, fixed time step, etc.

## Topics

### Articles

- <doc:QuickStart>
- <doc:PublicAPIContract>

### Simulation

- ``ConfettiSimulation``
- ``ConfettiSimulation/State``
- ``ConfettiConfig``

### Domain

- ``ConfettiCloud``
- ``ConfettoTraits``
- ``ConfettoState``

### Color

- ``ConfettiColorSource``


