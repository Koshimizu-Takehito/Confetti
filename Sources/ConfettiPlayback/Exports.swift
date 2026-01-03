// MARK: - Selective Re-exports from ConfettiCore

// Only expose types that users need to customize behavior.
// Internal types (ConfettiCloud, ConfettoTraits, ConfettoState, ConfettiSimulation)
// are intentionally hidden as implementation details.

// Re-export ConfettiConfig struct with all its static members (presets)
@_exported import struct ConfettiCore.ConfettiConfig

// Re-export ConfettiColorSource protocol
@_exported import protocol ConfettiCore.ConfettiColorSource

// Re-export ParticleRenderState (now part of ConfettiCore)
@_exported import struct ConfettiCore.ParticleRenderState
