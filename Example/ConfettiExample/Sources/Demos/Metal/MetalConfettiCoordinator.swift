import Metal
import MetalKit
import simd

// MARK: - MetalConfettiCoordinator

/// Coordinator that manages Metal rendering for confetti particles.
///
/// This class handles:
/// - Metal device and command queue setup
/// - Render pipeline state creation from compiled shaders
/// - Particle buffer management
/// - Drawing particles using instanced rendering
///
/// ## Usage
///
/// ```swift
/// let coordinator = MetalConfettiCoordinator(device: MTLCreateSystemDefaultDevice())
/// coordinator?.particleDataProvider = {
///     // Return array of ConfettiParticleData
/// }
/// ```
@MainActor
final class MetalConfettiCoordinator: NSObject, @MainActor MTKViewDelegate {
    // MARK: - Properties

    /// The Metal device.
    let device: any MTLDevice

    /// The command queue for submitting work to the GPU.
    private let commandQueue: any MTLCommandQueue

    /// The render pipeline state.
    private var renderPipelineState: (any MTLRenderPipelineState)?

    /// Buffer for particle data.
    private var particleBuffer: (any MTLBuffer)?

    /// Current particle count.
    private var particleCount: Int = 0

    /// Viewport size in points (not pixels).
    private var viewportSize: SIMD2<Float> = .zero

    /// Content scale factor (e.g., 2.0 or 3.0 for Retina displays).
    private var contentScaleFactor: Float = 1.0

    /// Callback to get current particle data.
    var particleDataProvider: (() -> [ConfettiParticleData])?

    // MARK: - Initialization

    /// Creates a new coordinator with the given Metal device.
    /// - Parameter device: The Metal device to use. Returns nil if device is nil.
    init?(device: (any MTLDevice)?) {
        guard let device, let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.device = device
        self.commandQueue = commandQueue
        super.init()
        buildPipeline()
    }

    // MARK: - Pipeline Setup

    private func buildPipeline() {
        guard let library = device.makeDefaultLibrary() else {
            print("Failed to load default Metal library")
            return
        }

        guard let vertexFunction = library.makeFunction(name: "confettiVertexShader"),
              let fragmentFunction = library.makeFunction(name: "confettiFragmentShader")
        else {
            print("Failed to load shader functions")
            return
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // Enable alpha blending for transparency
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Failed to create render pipeline: \(error)")
        }
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        #if canImport(UIKit)
        let scale = Float(view.contentScaleFactor)
        #elseif canImport(AppKit)
        let scale = Float(view.layer?.contentsScale ?? 1.0)
        #endif

        Task { @MainActor in
            contentScaleFactor = scale
            // Convert drawable size (pixels) to points
            viewportSize = SIMD2<Float>(Float(size.width), Float(size.height)) / scale
        }
    }

    func draw(in view: MTKView) {
        drawFrame(in: view)
    }

    // MARK: - Drawing

    private func drawFrame(in view: MTKView) {
        guard let renderPipelineState,
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer()
        else {
            return
        }

        // Get particle data from provider
        let particles = particleDataProvider?() ?? []
        particleCount = particles.count

        // Clear with transparent background
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

        guard particleCount > 0 else {
            // Just clear the screen when no particles
            if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                encoder.endEncoding()
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
            return
        }

        // Update particle buffer (grow if needed, reuse otherwise)
        let bufferSize = MemoryLayout<ConfettiParticleData>.stride * particleCount
        let needsNewBuffer = particleBuffer.map { $0.length < bufferSize } ?? true
        if needsNewBuffer {
            particleBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        }

        if let buffer = particleBuffer {
            let pointer = buffer.contents().bindMemory(to: ConfettiParticleData.self, capacity: particleCount)
            for (index, particle) in particles.enumerated() {
                pointer[index] = particle
            }
        }

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)

        var viewport = viewportSize
        encoder.setVertexBytes(&viewport, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)

        // Draw all particles as instanced quads (6 vertices per quad)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: particleCount)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
