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

The project follows a 3-layer modular architecture:

```
ConfettiUI (SwiftUI Views & Components)
    ↓
ConfettiPlayback (Playback Control & Rendering)
    ↓  
ConfettiCore (Internal Domain Models & Physics)
```

**Key Modules:**
- `/Sources/ConfettiCore/` - Internal module with domain models and physics simulation
- `/Sources/ConfettiPlayback/` - Public API for playback control and render state
- `/Sources/ConfettiUI/` - SwiftUI views and components
- `/Example/` - Complete demo app for iOS/macOS
- `/Tests/` - Unit tests using Swift Testing framework

## Key Files to Understand

1. `/Sources/ConfettiPlayback/Playback/ConfettiPlayer.swift` - Main API with video-player-like controls
2. `/Sources/ConfettiCore/Config/ConfettiConfig.swift` - Configuration system with presets
3. `/Sources/ConfettiUI/Views/ConfettiScreen.swift` - Primary SwiftUI component
4. `/Sources/ConfettiCore/Documentation.docc/Articles/PublicAPIContract.md` - Internal API contract

## Design Principles

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