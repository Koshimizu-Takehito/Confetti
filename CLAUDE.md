# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Confetti is a Swift package providing beautiful confetti particle animations for SwiftUI applications. It supports iOS 18+ and macOS 15+ with a clean, testable architecture.

## Development Commands

Use these Make commands for development:

```bash
make setup     # Install Mint and dependencies  
make build     # Build the package
make test      # Run tests
make lint      # Run SwiftLint
make format    # Format code with SwiftFormat
make ci        # Run all CI checks (required before PRs)
make open      # Open package in Xcode
make open-example # Open example project
```

Always run `make ci` before submitting pull requests to ensure all checks pass.

## Architecture

The project follows a 3-layer modular architecture with strict encapsulation:

```
ConfettiUI (SwiftUI Views & Components)
    ↓ Uses public API only
ConfettiPlayback (Playback Control & Rendering)
    ↓ Exposes minimal interface via computed properties
ConfettiCore (Internal Domain Models & Physics) - Hidden from external access
```

**Key Modules:**
- `/Sources/ConfettiCore/` - **Internal module** - Core physics engine, state machine, and domain models (not exposed publicly)
- `/Sources/ConfettiPlayback/` - **Public API** - `ConfettiPlayer` with encapsulated interface; hides `ConfettiSimulation` internals
- `/Sources/ConfettiUI/` - **UI layer** - SwiftUI views and components built on public API
- `/Example/` - Complete demo app for iOS/macOS
- `/Tests/` - Unit tests using Swift Testing framework

**Encapsulation Strategy:**
- `ConfettiPlayer` exposes only: `renderStates`, `currentTime`, `duration`, `state` (all read-only computed properties)
- Internal `ConfettiSimulation` is private, preventing external state manipulation
- SSoT maintained through version-based cache invalidation (~180x speedup)

## Key Files to Understand

1. `/Sources/ConfettiPlayback/Playback/ConfettiPlayer.swift` - Main public API with video-player-like controls; encapsulates internal `ConfettiSimulation`
2. `/Sources/ConfettiCore/Simulation/ConfettiSimulation.swift` - Internal SSoT state machine with @Observable pattern and version-based caching
3. `/Sources/ConfettiCore/Config/ConfettiConfig.swift` - Configuration system with presets
4. `/Sources/ConfettiUI/Views/ConfettiScreen.swift` - Primary SwiftUI component
5. `/Sources/ConfettiCore/Documentation.docc/Articles/PublicAPIContract.md` - v2.0.0 breaking changes and SSoT architecture documentation

## Design Principles

- **Single Source of Truth (SSoT)** - State managed by `ConfettiSimulation` with version-based cache invalidation
- **Strong encapsulation** - Internal implementation hidden; only necessary interface exposed via computed properties
- **Fixed time step simulation** - Consistent animation across refresh rates
- **Deterministic seeking** - Seek to any time with consistent results
- **Injectable randomness** - Enables testable code via `RandomNumberGenerator`
- **Separation of concerns** - Core logic is UI-independent

## Development Guidelines

- **Swift 6.0** with strict concurrency enabled
- **Swift Testing framework** (not XCTest)
- **Japanese comments** in test files
- **Seeded random generation** for deterministic tests
- **Line length**: 150 chars (warning), 200 chars (error)

## Branch Structure

- **Main branch**: `main`
- **Development branch**: `develop` (currently active)
- Use conventional commits and ensure CI passes before merging

## Testing

Tests use deterministic `SeededRandomNumberGenerator` for reproducible results. Run specific test with:

```bash
swift test --filter "TestClassName"
```