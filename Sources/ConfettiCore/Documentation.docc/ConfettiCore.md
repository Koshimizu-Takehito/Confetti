# ``ConfettiCore``

A core module that provides UI-independent confetti simulation.

`ConfettiCore` handles **physics simulation** and **domain models** without depending on UI frameworks like SwiftUI. Use `ConfettiUI` for UI components.

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


