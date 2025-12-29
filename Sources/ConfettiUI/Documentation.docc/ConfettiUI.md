# ``ConfettiUI``

A SwiftUI module for displaying confetti animations.

`ConfettiUI` provides ready-to-use SwiftUI views for confetti animations.

## Overview

`ConfettiUI` re-exports `ConfettiPlayback`, so you only need to import `ConfettiUI` to access playback and rendering APIs.

For custom rendering (Metal, SpriteKit, etc.), you can import `ConfettiPlayback` directly (it does not provide SwiftUI views, but it intentionally uses UIKit/AppKit for frame driving, and SwiftUI color utilities via generated helpers).

## Getting Started

- ``ConfettiScreen``: Preset view with trigger button (easiest to use)
- ``ConfettiPlayer``: Video-player-like playback control (play/pause/resume/seek/stop)
- ``ConfettiPlayerScreen``: Full-featured view with playback controls

## Topics

### Views

- ``ConfettiScreen``
- ``ConfettiCanvas``
- ``ConfettiPlayerScreen``
- ``ConfettiPlayerScreenWithDefaultPlayer``

### Playback (from ConfettiPlayback)

- ``ConfettiPlayer``
- ``ConfettiRenderer``
- ``ParticleRenderState``

### Trigger

- ``ConfettiTriggerButton``
- ``ConfettiTriggerButtonStyle``
- ``SwiftUI/View/confettiTriggerButtonStyle(_:)``


