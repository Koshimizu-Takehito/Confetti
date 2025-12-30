# ``ConfettiPlayback``

Playback control and rendering for confetti animations.

`ConfettiPlayback` provides video-player-like controls for confetti animations. Use this module when you need playback control with custom rendering (Metal, SpriteKit, UIKit, etc.).

## Overview

`ConfettiPlayback` builds on `ConfettiCore` to provide:
- Frame-synchronized playback via `DisplayLinkDriver`
- Video-player-like API (play/pause/resume/seek/stop)
- Render state conversion via `ConfettiRenderer`
- Default 7-color palette via `DefaultColorSource`

### Dependencies (intentional)

`ConfettiPlayback` is designed as a **playback layer** and intentionally depends on:

- **UIKit/AppKit**: for frame driving (`CADisplayLink` on iOS, `Timer` on macOS)
- **SwiftUI**: for `Color` in `ParticleRenderState`

> **Note**: `ConfettiCore` is an internal module and is not exposed as a public product.
> The simulation logic is UI-independent internally, but library users should use `ConfettiPlayback` or `ConfettiUI`.

## Getting Started

- ``ConfettiPlayer``: Main playback controller with video-player-like API
- ``ConfettiRenderer``: Converts simulation state to render states

## Topics

### Playback

- ``ConfettiPlayer``

### Rendering

- ``ConfettiRenderer``
- ``ParticleRenderState``

### Color

- ``DefaultColorSource``


