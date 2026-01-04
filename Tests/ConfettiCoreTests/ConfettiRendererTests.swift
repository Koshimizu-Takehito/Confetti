@testable import ConfettiCore
@testable import ConfettiPlayback
import CoreGraphics
import Foundation
import Testing

// MARK: - TestColors

/// Test color palette
private enum TestColors {
    static let red = CGColor(red: 1, green: 0.4, blue: 0.4, alpha: 1)
    static let blue = CGColor(red: 0.4, green: 0.8, blue: 1, alpha: 1)
    static let green = CGColor(red: 0.4, green: 1, blue: 0.6, alpha: 1)
}

// MARK: - Test Helpers

/// Creates a simple ConfettoTraits with default rotation and wind values
private func makeTraits(
    width: CGFloat,
    height: CGFloat,
    color: CGColor
) -> ConfettoTraits {
    ConfettoTraits(
        width: width,
        height: height,
        color: color,
        rotationXSpeed: 0,
        rotationYSpeed: 0,
        windForce: 0
    )
}

/// Creates a simple ConfettoState with default values
private func makeState(
    position: CGPoint,
    rotationX: Double = 0,
    rotationY: Double = 0,
    opacity: Double = 1.0
) -> ConfettoState {
    ConfettoState(
        position: position,
        velocity: .zero,
        rotationX: rotationX,
        rotationY: rotationY,
        opacity: opacity
    )
}

// MARK: - Basic Conversion Tests

@Test("Basic conversion: Cloud is converted to RenderStates")
func renderStatesConvertsCloudToRenderStates() {
    let traits = [
        ConfettoTraits(
            width: 10,
            height: 8,
            color: TestColors.red,
            rotationXSpeed: 0.5,
            rotationYSpeed: 0.3,
            windForce: 0.1
        ),
    ]
    let states = [
        ConfettoState(
            position: CGPoint(x: 100, y: 200),
            velocity: CGVector(dx: 1, dy: 2),
            rotationX: 0,
            rotationY: 0,
            opacity: 1.0
        ),
    ]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates.count == 1)
    #expect(renderStates[0].id == traits[0].id)
    #expect(renderStates[0].opacity > 0)
}

@Test("Basic conversion: Empty Cloud returns empty array")
func renderStatesEmptyCloudReturnsEmptyArray() {
    let cloud = ConfettiCloud(traits: [], states: [], aliveCount: 0)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates.isEmpty)
}

@Test("Basic conversion: Multiple particles are all converted")
func renderStatesMultipleParticlesConvertsAll() {
    let traits = [
        makeTraits(width: 10, height: 10, color: TestColors.red),
        makeTraits(width: 20, height: 20, color: TestColors.blue),
        makeTraits(width: 15, height: 15, color: TestColors.green),
    ]
    let states = [
        makeState(position: CGPoint(x: 10, y: 10)),
        makeState(position: CGPoint(x: 20, y: 20)),
        makeState(position: CGPoint(x: 30, y: 30)),
    ]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 3)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates.count == 3)
    #expect(renderStates[0].id == traits[0].id)
    #expect(renderStates[1].id == traits[1].id)
    #expect(renderStates[2].id == traits[2].id)
}

@Test("Basic conversion: Only aliveCount particles are converted when less than array size")
func renderStatesAliveCountLessThanArraySizeOnlyConvertsAlive() {
    let traits = [
        makeTraits(width: 10, height: 10, color: TestColors.red),
        makeTraits(width: 20, height: 20, color: TestColors.blue),
        makeTraits(width: 15, height: 15, color: TestColors.green),
    ]
    let states = [
        makeState(position: CGPoint(x: 10, y: 10)),
        makeState(position: CGPoint(x: 20, y: 20)),
        makeState(position: CGPoint(x: 30, y: 30), opacity: 0.0),
    ]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 2)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates.count == 2)
}

// MARK: - DepthScaleTestCase

/// Depth scale test cases
struct DepthScaleTestCase: Sendable {
    let name: String
    let rotationY: Double
    let expectedScale: CGFloat

    static let cases: [Self] = [
        Self(name: "rotationY=0 max scale", rotationY: 0, expectedScale: 1.0),
        Self(
            name: "rotationY=π/4 mid scale",
            rotationY: .pi / 4,
            expectedScale: 0.5 + 0.5 * abs(cos(.pi / 4))
        ),
        Self(name: "rotationY=π/2 min scale", rotationY: .pi / 2, expectedScale: 0.5),
        Self(name: "rotationY=π max scale", rotationY: .pi, expectedScale: 1.0),
        Self(name: "rotationY=-π/2 min scale", rotationY: -.pi / 2, expectedScale: 0.5),
    ]
}

@Test("Depth scale: Scale changes by Y rotation", arguments: DepthScaleTestCase.cases)
func depthScaleByRotationY(testCase: DepthScaleTestCase) {
    let baseSize: CGFloat = 10
    let traits = [makeTraits(width: baseSize, height: baseSize, color: TestColors.red)]
    let states = [makeState(position: CGPoint(x: 50, y: 50), rotationY: testCase.rotationY)]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    let expectedSize = baseSize * testCase.expectedScale
    #expect(abs(renderStates[0].rect.width - expectedSize) < 0.01, "\(testCase.name)")
    #expect(abs(renderStates[0].rect.height - expectedSize) < 0.01, "\(testCase.name)")
}

// MARK: - OpacityModulationTestCase

/// Opacity modulation test cases
struct OpacityModulationTestCase: Sendable {
    let name: String
    let rotationX: Double
    let baseOpacity: Double
    let expectedOpacity: Double

    static let cases: [Self] = [
        // X rotation modulation
        Self(
            name: "rotationX=0 max modulation",
            rotationX: 0, baseOpacity: 0.5, expectedOpacity: 0.5
        ),
        Self(
            name: "rotationX=π/2 min modulation",
            rotationX: .pi / 2, baseOpacity: 1.0, expectedOpacity: 0.7
        ),
        Self(
            name: "rotationX=π max modulation",
            rotationX: .pi, baseOpacity: 1.0, expectedOpacity: 1.0
        ),
        // Base opacity
        Self(
            name: "opacity=0 stays 0",
            rotationX: 0, baseOpacity: 0.0, expectedOpacity: 0.0
        ),
        Self(
            name: "opacity=1.0 max",
            rotationX: 0, baseOpacity: 1.0, expectedOpacity: 1.0
        ),
    ]
}

@Test("Opacity modulation: Calculation from X rotation and base opacity", arguments: OpacityModulationTestCase.cases)
func opacityModulationCalculation(testCase: OpacityModulationTestCase) {
    let traits = [makeTraits(width: 10, height: 10, color: TestColors.red)]
    let states = [
        makeState(
            position: CGPoint(x: 50, y: 50),
            rotationX: testCase.rotationX,
            opacity: testCase.baseOpacity
        ),
    ]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(abs(renderStates[0].opacity - testCase.expectedOpacity) < 0.01, "\(testCase.name)")
}

@Test("Opacity: Clamped to valid range (0...1)", arguments: [0.0, 0.25, 0.5, 0.75, 1.0] as [Double])
func opacityInValidRange(baseOpacity: Double) {
    let traits = [makeTraits(width: 10, height: 10, color: TestColors.red)]
    let states = [makeState(position: CGPoint(x: 50, y: 50), opacity: baseOpacity)]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates[0].opacity >= 0.0)
    #expect(renderStates[0].opacity <= 1.0)
}

// MARK: - ZRotationTestCase

/// Z rotation test cases
struct ZRotationTestCase: Sendable {
    let name: String
    let rotationX: Double
    let expectedZRotation: Double

    static let cases: [Self] = [
        Self(name: "rotationX=0 no rotation", rotationX: 0, expectedZRotation: 0),
        Self(
            name: "rotationX=π/4 mid positive",
            rotationX: .pi / 4,
            expectedZRotation: sin(.pi / 4) * 0.3
        ),
        Self(name: "rotationX=π/2 max positive", rotationX: .pi / 2, expectedZRotation: 0.3),
        Self(name: "rotationX=-π/2 max negative", rotationX: -.pi / 2, expectedZRotation: -0.3),
        Self(name: "rotationX=π no rotation", rotationX: .pi, expectedZRotation: 0),
    ]
}

@Test("Z rotation: Z rotation calculation from X rotation", arguments: ZRotationTestCase.cases)
func zRotationByRotationX(testCase: ZRotationTestCase) {
    let traits = [makeTraits(width: 10, height: 10, color: TestColors.red)]
    let states = [makeState(position: CGPoint(x: 50, y: 50), rotationX: testCase.rotationX)]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(abs(renderStates[0].zRotation - testCase.expectedZRotation) < 0.01, "\(testCase.name)")
}

// MARK: - RectTestCase

/// Rect calculation test cases
struct RectTestCase: Sendable {
    let name: String
    let position: CGPoint
    let width: CGFloat
    let height: CGFloat
    let expectedOrigin: CGPoint
    let expectedSize: CGSize

    static let cases: [Self] = [
        Self(
            name: "Center placement",
            position: CGPoint(x: 100, y: 200),
            width: 20, height: 10,
            expectedOrigin: CGPoint(x: 90, y: 195),
            expectedSize: CGSize(width: 20, height: 10)
        ),
        Self(
            name: "Size 0",
            position: CGPoint(x: 50, y: 50),
            width: 0, height: 0,
            expectedOrigin: CGPoint(x: 50, y: 50),
            expectedSize: CGSize.zero
        ),
        Self(
            name: "Negative coordinates",
            position: CGPoint(x: -50, y: -100),
            width: 10, height: 10,
            expectedOrigin: CGPoint(x: -55, y: -105),
            expectedSize: CGSize(width: 10, height: 10)
        ),
        Self(
            name: "Origin",
            position: CGPoint.zero,
            width: 20, height: 20,
            expectedOrigin: CGPoint(x: -10, y: -10),
            expectedSize: CGSize(width: 20, height: 20)
        ),
        Self(
            name: "Asymmetric size",
            position: CGPoint(x: 100, y: 100),
            width: 30, height: 10,
            expectedOrigin: CGPoint(x: 85, y: 95),
            expectedSize: CGSize(width: 30, height: 10)
        ),
    ]
}

@Test("Rect: Correct rect calculated from position and size", arguments: RectTestCase.cases)
func rectCalculation(testCase: RectTestCase) {
    let traits = [makeTraits(width: testCase.width, height: testCase.height, color: TestColors.red)]
    let states = [makeState(position: testCase.position)]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    let name = testCase.name
    #expect(renderStates[0].rect.origin.x == testCase.expectedOrigin.x, "\(name) - origin.x")
    #expect(renderStates[0].rect.origin.y == testCase.expectedOrigin.y, "\(name) - origin.y")
    #expect(renderStates[0].rect.width == testCase.expectedSize.width, "\(name) - width")
    #expect(renderStates[0].rect.height == testCase.expectedSize.height, "\(name) - height")
}

// MARK: - Property Preservation Tests

@Test("Property: id is preserved from traits")
func idPreservedFromTraits() {
    let traits = [makeTraits(width: 10, height: 10, color: TestColors.red)]
    let expectedID = traits[0].id
    let states = [makeState(position: CGPoint(x: 50, y: 50))]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    let renderStates = ConfettiRenderer.renderStates(from: cloud)

    #expect(renderStates[0].id == expectedID)
}

// MARK: - Buffer Reuse Tests

@Test("Buffer reuse: Renderer reuses internal buffer")
func rendererReusesBuffer() {
    var renderer = ConfettiRenderer(initialCapacity: 10)

    let traits1 = [
        ConfettoTraits(
            width: 10,
            height: 10,
            color: TestColors.red,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
        ConfettoTraits(
            width: 20,
            height: 20,
            color: TestColors.blue,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
    ]
    let states1 = [
        ConfettoState(position: CGPoint(x: 10, y: 10), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0),
        ConfettoState(position: CGPoint(x: 20, y: 20), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0),
    ]
    let cloud1 = ConfettiCloud(traits: traits1, states: states1, aliveCount: 2)

    let renderStates1 = renderer.update(from: cloud1)
    #expect(renderer.activeCount == 2)
    #expect(renderStates1.count == 2)

    // Second update with different data
    let traits2 = [
        ConfettoTraits(
            width: 15,
            height: 15,
            color: TestColors.green,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
    ]
    let states2 = [
        ConfettoState(position: CGPoint(x: 30, y: 30), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 0.5),
    ]
    let cloud2 = ConfettiCloud(traits: traits2, states: states2, aliveCount: 1)

    let renderStates2 = renderer.update(from: cloud2)
    #expect(renderer.activeCount == 1)
    #expect(renderStates2.count == 1)
    #expect(renderStates2[0].id == traits2[0].id)
}

@Test("Buffer reuse: Clear resets activeCount")
func rendererClearResetsActiveCount() {
    var renderer = ConfettiRenderer()

    let traits = [
        ConfettoTraits(
            width: 10,
            height: 10,
            color: TestColors.red,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
    ]
    let states = [
        ConfettoState(position: CGPoint(x: 10, y: 10), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0),
    ]
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 1)

    _ = renderer.update(from: cloud)
    #expect(renderer.activeCount == 1)

    renderer.clear()
    #expect(renderer.activeCount == 0)
}

@Test("Buffer reuse: Reset releases buffer memory")
func rendererResetReleasesMemory() {
    var renderer = ConfettiRenderer(initialCapacity: 100)

    let traits = (0 ..< 50).map { _ in
        ConfettoTraits(width: 10, height: 10, color: TestColors.red, rotationXSpeed: 0, rotationYSpeed: 0, windForce: 0)
    }
    let states = (0 ..< 50).map { _ in
        ConfettoState(position: CGPoint(x: 10, y: 10), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0)
    }
    let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: 50)

    _ = renderer.update(from: cloud)
    #expect(renderer.activeCount == 50)

    renderer.reset()
    #expect(renderer.activeCount == 0)
}

@Test("Buffer reuse: Buffer grows when needed")
func rendererBufferGrowsWhenNeeded() {
    var renderer = ConfettiRenderer(initialCapacity: 2)

    // First update with 2 particles
    let traits1 = [
        ConfettoTraits(
            width: 10,
            height: 10,
            color: TestColors.red,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
        ConfettoTraits(
            width: 10,
            height: 10,
            color: TestColors.blue,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        ),
    ]
    let states1 = [
        ConfettoState(position: CGPoint(x: 10, y: 10), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0),
        ConfettoState(position: CGPoint(x: 20, y: 20), velocity: .zero, rotationX: 0, rotationY: 0, opacity: 1.0),
    ]
    let cloud1 = ConfettiCloud(traits: traits1, states: states1, aliveCount: 2)

    _ = renderer.update(from: cloud1)
    #expect(renderer.activeCount == 2)

    // Second update with 5 particles (needs buffer growth)
    let traits2 = (0 ..< 5).map { _ in
        ConfettoTraits(
            width: 10,
            height: 10,
            color: TestColors.green,
            rotationXSpeed: 0,
            rotationYSpeed: 0,
            windForce: 0
        )
    }
    let states2 = (0 ..< 5).map { i in
        ConfettoState(
            position: CGPoint(x: CGFloat(i * 10), y: 10),
            velocity: .zero,
            rotationX: 0,
            rotationY: 0,
            opacity: 1.0
        )
    }
    let cloud2 = ConfettiCloud(traits: traits2, states: states2, aliveCount: 5)

    let renderStates = renderer.update(from: cloud2)
    #expect(renderer.activeCount == 5)
    #expect(renderStates.count == 5)
}

@Test("Buffer reuse: Multiple updates produce correct results")
func rendererMultipleUpdatesProduceCorrectResults() {
    var renderer = ConfettiRenderer(initialCapacity: 10)

    for i in 1 ... 5 {
        let traits = (0 ..< i).map { _ in
            ConfettoTraits(
                width: CGFloat(i * 10),
                height: CGFloat(i * 10),
                color: TestColors.red,
                rotationXSpeed: 0,
                rotationYSpeed: 0,
                windForce: 0
            )
        }
        let states = (0 ..< i).map { j in
            ConfettoState(
                position: CGPoint(x: CGFloat(j * 10), y: CGFloat(j * 10)),
                velocity: .zero,
                rotationX: 0,
                rotationY: 0,
                opacity: Double(i) / 5.0
            )
        }
        let cloud = ConfettiCloud(traits: traits, states: states, aliveCount: i)

        let renderStates = renderer.update(from: cloud)

        #expect(renderer.activeCount == i, "Iteration \(i): activeCount should be \(i)")
        #expect(renderStates.count == i, "Iteration \(i): renderStates count should be \(i)")
    }
}
