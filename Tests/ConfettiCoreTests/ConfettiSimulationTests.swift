@testable import ConfettiCore
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

// MARK: - ConstantColorSource

/// A color source that always returns the same color (for testing)
private struct ConstantColorSource: ConfettiColorSource {
    var color: CGColor = TestColors.red
    mutating func nextColor(using _: inout some RandomNumberGenerator) -> CGColor { color }
}

// MARK: - ライフサイクルテスト

@Test("start: 指定したパーティクル数が生成される")
func startCreatesExpectedParticleCount() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 4

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(timeIntervalSince1970: 0),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )

    #expect(simulation.state.isRunning)
    #expect(simulation.state.cloud?.aliveCount == 10)
}

@Test("tick: duration経過後にシミュレーションが停止する")
func tickStopsAfterDuration() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 3
    configuration.lifecycle.duration = 0.1
    configuration.lifecycle.fadeOutDuration = 0.05
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)
    #expect(simulation.state.isRunning)

    simulation.tick(at: startTime.addingTimeInterval(0.05), bounds: bounds)
    simulation.tick(at: startTime.addingTimeInterval(0.10), bounds: bounds)
    simulation.tick(at: startTime.addingTimeInterval(0.15), bounds: bounds)
    simulation.tick(at: startTime.addingTimeInterval(0.20), bounds: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

@Test("stop: 状態がクリアされる")
func stopClearsState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )
    #expect(simulation.state.isRunning)

    simulation.stop()
    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

// MARK: - 一時停止・再開テスト

@Test("pause: シミュレーションの進行が停止する")
func pauseStopsSimulationProgress() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)
    #expect(simulation.state.isPlaying)
    #expect(!simulation.state.isPaused)

    simulation.tick(at: startTime.addingTimeInterval(0.1), bounds: bounds)
    let timeBeforePause = simulation.currentTime

    simulation.pause()
    #expect(simulation.state.isRunning)
    #expect(simulation.state.isPaused)
    #expect(!simulation.state.isPlaying)

    simulation.tick(at: startTime.addingTimeInterval(0.2), bounds: bounds)
    #expect(simulation.currentTime == timeBeforePause)
}

@Test("resume: 一時停止からシミュレーションが再開する")
func resumeContinuesSimulation() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)
    simulation.tick(at: startTime.addingTimeInterval(0.1), bounds: bounds)
    let timeBeforePause = simulation.currentTime

    simulation.pause()
    #expect(simulation.state.isPaused)

    let resumeTime = startTime.addingTimeInterval(1.0)
    simulation.resume(at: resumeTime)
    #expect(!simulation.state.isPaused)
    #expect(simulation.state.isPlaying)

    simulation.tick(at: resumeTime.addingTimeInterval(0.1), bounds: bounds)
    #expect(simulation.currentTime > timeBeforePause)
}

// MARK: - シークテスト

@Test("seek: 指定した時刻にジャンプする")
func seekJumpsToTargetTime() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.seek(to: 1.5, bounds: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(1.5 / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime
    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("seek: 範囲外の値は有効範囲にクランプされる")
func seekClampsToValidRange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 2.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.seek(to: 10.0, bounds: bounds)
    #expect(simulation.currentTime <= configuration.lifecycle.duration)

    simulation.seek(to: -1.0, bounds: bounds)
    #expect(simulation.currentTime >= 0)
}

@Test("seek: 初期状態が保持され再利用される")
func seekPreservesInitialState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.seek(to: 1.0, bounds: bounds)
    simulation.seek(to: 0.0, bounds: bounds)

    #expect(simulation.currentTime == 0)
    #expect(simulation.state.cloud?.aliveCount == 5)
}

// MARK: - プロパティテスト

@Test("duration: configurationの値と一致する")
func durationMatchesConfiguration() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.duration = 5.0

    let simulation = ConfettiSimulation(configuration: configuration)
    #expect(simulation.duration == 5.0)
}

@Test("currentTime: 開始時は0である")
func currentTimeStartsAtZero() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)
    #expect(simulation.currentTime == 0)
}

// MARK: - 境界値分析テスト（パラメタライズド）

@Test(
    "境界値: particleCount の様々な値でパーティクルが正しく生成される",
    arguments: [0, 1, 5, 100, 1000]
)
func particleCountCreatesExpectedParticles(count: Int) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = count

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)

    #expect(simulation.state.isRunning)
    #expect(simulation.state.cloud?.aliveCount == count)
}

@Test("境界値: seek(0) で初期状態にリセットされる")
func seekExactlyZeroResetsToInitialState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)
    let initialPositions = simulation.state.cloud?.states.map(\.position)

    simulation.seek(to: 1.0, bounds: bounds)
    simulation.seek(to: 0.0, bounds: bounds)

    let resetPositions = simulation.state.cloud?.states.map(\.position)
    #expect(simulation.currentTime == 0)
    #expect(initialPositions == resetPositions)
}

@Test("境界値: seek(duration) で終了時刻に到達する")
func seekExactlyDurationAdvancesToEnd() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 1.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)
    simulation.seek(to: configuration.lifecycle.duration, bounds: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(configuration.lifecycle.duration / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime
    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("境界値: 非常に小さいboundsでパーティクルがすぐに境界外に出る")
func boundsVerySmallParticlesGoOutOfBoundsQuickly() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 10.0
    configuration.spawn.boundaryMargin = 0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 1, height: 1)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    for i in 1 ... 10 {
        simulation.tick(at: startTime.addingTimeInterval(Double(i) * 0.05), bounds: bounds)
    }

    #expect((simulation.state.cloud?.aliveCount ?? 0) < 5)
}

// MARK: - OutOfBoundsTestCase

/// 境界外判定テスト用のケース
struct OutOfBoundsTestCase: Sendable {
    let name: String
    let position: CGPoint
    let shouldBeRemoved: Bool

    static let cases: [Self] = [
        Self(name: "左端超過", position: CGPoint(x: -100, y: 50), shouldBeRemoved: true),
        Self(name: "右端超過", position: CGPoint(x: 200, y: 50), shouldBeRemoved: true),
        Self(name: "下端超過", position: CGPoint(x: 50, y: 200), shouldBeRemoved: true),
        Self(name: "マージン内(左)", position: CGPoint(x: -5, y: 50), shouldBeRemoved: false),
        Self(name: "マージン内(右)", position: CGPoint(x: 105, y: 50), shouldBeRemoved: false),
        Self(name: "境界ちょうど(左)", position: CGPoint(x: -10, y: 50), shouldBeRemoved: false),
        Self(name: "中央", position: CGPoint(x: 50, y: 50), shouldBeRemoved: false),
    ]
}

@Test(
    "境界外判定: パーティクル位置による削除判定",
    arguments: OutOfBoundsTestCase.cases
)
func outOfBoundsParticleRemoval(testCase: OutOfBoundsTestCase) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10
    configuration.spawn.boundaryMargin = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.wind.forceRange = 0 ... 0
    configuration.physics.gravity = 0 // 重力も無効化

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 100, height: 100)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = testCase.position
        cloud.states[0].velocity = .zero
    }

    simulation.tick(at: startTime.addingTimeInterval(configuration.physics.fixedDeltaTime), bounds: bounds)

    if testCase.shouldBeRemoved {
        #expect(simulation.state.cloud?.aliveCount == 0, "位置 \(testCase.name) で削除されるべき")
    } else {
        #expect(simulation.state.cloud?.aliveCount == 1, "位置 \(testCase.name) で保持されるべき")
    }
}

// MARK: - 状態遷移テスト

@Test("状態遷移: stopped → running")
func stateTransitionStoppedToRunning() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPlaying)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )

    #expect(simulation.state.isRunning)
    #expect(simulation.state.isPlaying)
    #expect(!simulation.state.isPaused)
}

@Test("状態遷移: running → paused → running")
func stateTransitionRunningToPausedToRunning() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: startTime,
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )
    #expect(simulation.state.isPlaying)

    simulation.pause()
    #expect(simulation.state.isRunning)
    #expect(simulation.state.isPaused)
    #expect(!simulation.state.isPlaying)

    simulation.resume(at: startTime.addingTimeInterval(1.0))
    #expect(simulation.state.isRunning)
    #expect(!simulation.state.isPaused)
    #expect(simulation.state.isPlaying)
}

@Test("状態遷移: paused → stopped")
func stateTransitionPausedToStopped() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )
    simulation.pause()
    #expect(simulation.state.isPaused)

    simulation.stop()
    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPaused)
    #expect(!simulation.state.isPlaying)
}

@Test("状態遷移: pause中のpauseは無視される")
func stateTransitionPauseWhenAlreadyPausedNoChange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )
    simulation.pause()
    let stateAfterFirstPause = simulation.state

    simulation.pause()
    #expect(simulation.state.isPaused == stateAfterFirstPause.isPaused)
    #expect(simulation.state.isRunning == stateAfterFirstPause.isRunning)
}

@Test("状態遷移: pause中でないresumeは無視される")
func stateTransitionResumeWhenNotPausedNoChange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        bounds: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        using: &numberGenerator
    )
    let stateBeforeResume = simulation.state

    simulation.resume(at: Date())
    #expect(simulation.state.isPaused == stateBeforeResume.isPaused)
    #expect(simulation.state.isPlaying == stateBeforeResume.isPlaying)
}

@Test("状態遷移: 未開始状態でのpauseは無視される")
func stateTransitionPauseWhenNotRunningNoChange() {
    var simulation = ConfettiSimulation(configuration: ConfettiConfig())

    #expect(!simulation.state.isRunning)

    simulation.pause()
    #expect(!simulation.state.isPaused)
    #expect(!simulation.state.isRunning)
}

@Test("状態遷移: 未開始状態でのresumeは無視される")
func stateTransitionResumeWhenNotRunningNoChange() {
    var simulation = ConfettiSimulation(configuration: ConfettiConfig())

    #expect(!simulation.state.isRunning)

    simulation.resume(at: Date())
    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPlaying)
}

// MARK: - エラー推測・エッジケーステスト

@Test("エッジケース: 最小のfixedDeltaTimeでシミュレーションが正常動作する")
func tickWithMinimumFixedDeltaTimeWorksNormally() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 240.0 // Minimum valid value

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.tick(at: startTime.addingTimeInterval(0.1), bounds: bounds)
    #expect(simulation.state.isRunning)
    #expect(simulation.currentTime > 0)
}

@Test("エッジケース: 同一時刻でtickしても進まない")
func tickWithSameTimeDoesNotAdvance() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.tick(at: startTime, bounds: bounds)
    #expect(simulation.currentTime == 0)
}

@Test("エッジケース: 大きな時間ジャンプはステップ数が制限される")
func tickWithLargeTimeJumpLimitsStepsPerTick() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.tick(at: startTime.addingTimeInterval(10.0), bounds: bounds)

    #expect(simulation.currentTime < 1.0)
}

@Test("エッジケース: 開始前のtickは無視される")
func tickBeforeStartNoChange() {
    var simulation = ConfettiSimulation(configuration: ConfettiConfig())
    let bounds = CGSize(width: 300, height: 600)

    simulation.tick(at: Date(), bounds: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

@Test("エッジケース: 開始前のseekは無視される")
func seekBeforeStartNoChange() {
    var simulation = ConfettiSimulation(configuration: ConfettiConfig())
    let bounds = CGSize(width: 300, height: 600)

    simulation.seek(to: 1.0, bounds: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.currentTime == 0)
}

@Test("エッジケース: 複数回のstartで状態がリセットされる")
func multipleStartsResetsState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)
    simulation.tick(at: startTime.addingTimeInterval(0.5), bounds: bounds)
    let timeAfterFirstRun = simulation.currentTime
    #expect(timeAfterFirstRun > 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)
    #expect(simulation.currentTime == 0)
    #expect(simulation.state.cloud?.aliveCount == 5)
}

// MARK: - 決定論性テスト

@Test("決定論性: 同じシードで同じ結果になる")
func determinismSameSeedProducesSameResults() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    var simulation1 = ConfettiSimulation(configuration: configuration)
    var rng1: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation1.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &rng1)
    simulation1.tick(at: startTime.addingTimeInterval(0.1), bounds: bounds)
    let positions1 = simulation1.state.cloud?.states.map(\.position)

    var simulation2 = ConfettiSimulation(configuration: configuration)
    var rng2: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation2.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &rng2)
    simulation2.tick(at: startTime.addingTimeInterval(0.1), bounds: bounds)
    let positions2 = simulation2.state.cloud?.states.map(\.position)

    #expect(positions1 == positions2)
}

@Test("決定論性: 異なるシードで異なる結果になる")
func determinismDifferentSeedsProduceDifferentResults() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    var simulation1 = ConfettiSimulation(configuration: configuration)
    var rng1: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    simulation1.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &rng1)
    let velocities1 = simulation1.state.cloud?.states.map(\.velocity)

    var simulation2 = ConfettiSimulation(configuration: configuration)
    var rng2: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 2)
    simulation2.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &rng2)
    let velocities2 = simulation2.state.cloud?.states.map(\.velocity)

    #expect(velocities1 != velocities2)
}

@Test("決定論性: seekが決定論的である")
func seekIsDeterministic() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    var simulation = ConfettiSimulation(configuration: configuration)
    var rng: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &rng)
    simulation.seek(to: 1.0, bounds: bounds)
    let positionsAfterSeek = simulation.state.cloud?.states.map(\.position)

    simulation.seek(to: 0, bounds: bounds)
    simulation.seek(to: 1.0, bounds: bounds)
    let positionsAfterReSeek = simulation.state.cloud?.states.map(\.position)

    #expect(positionsAfterSeek == positionsAfterReSeek)
}

// MARK: - ホワイトボックステスト（物理演算分岐カバレッジ）

@Test("物理演算: 重力によりパーティクルが下方向に加速する")
func physicsGravityAcceleratesDownward() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 1000 // 明確な重力
    configuration.physics.drag = 1.0 // ドラッグなし
    configuration.wind.forceRange = 0 ... 0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    // 初期状態を固定
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 100)
        cloud.states[0].velocity = CGVector.zero
    }

    let initialY = simulation.state.cloud?.states[0].position.y ?? 0

    // 複数フレーム進める
    for i in 1 ... 10 {
        simulation.tick(
            at: startTime.addingTimeInterval(Double(i) * configuration.physics.fixedDeltaTime),
            bounds: bounds
        )
    }

    let finalY = simulation.state.cloud?.states[0].position.y ?? 0

    // 重力により下方向に移動（Y座標が増加）
    #expect(finalY > initialY, "重力によりY座標が増加するべき")
}

@Test("物理演算: ドラッグにより速度が減衰する")
func physicsDragDeceleratesVelocity() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 0 // 重力なし
    configuration.physics.drag = 0.9 // 10%減衰
    configuration.wind.forceRange = 0 ... 0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    // 初速度を設定
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 300)
        cloud.states[0].velocity = CGVector(dx: 100, dy: 0)
    }

    let initialVelocityX = simulation.state.cloud?.states[0].velocity.dx ?? 0

    // 1フレーム進める
    simulation.tick(at: startTime.addingTimeInterval(configuration.physics.fixedDeltaTime), bounds: bounds)

    let finalVelocityX = simulation.state.cloud?.states[0].velocity.dx ?? 0

    // ドラッグにより速度が減衰
    #expect(finalVelocityX < initialVelocityX, "ドラッグにより速度が減衰するべき")
}

@Test("物理演算: 終端速度を超えない")
func physicsTerminalVelocityNotExceeded() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 10000 // 非常に強い重力
    configuration.physics.terminalVelocity = 100
    configuration.physics.drag = 1.0
    configuration.wind.forceRange = 0 ... 0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 10000)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 100)
        cloud.states[0].velocity = CGVector.zero
    }

    // 多くのフレーム進める
    for i in 1 ... 100 {
        simulation.tick(
            at: startTime.addingTimeInterval(Double(i) * configuration.physics.fixedDeltaTime),
            bounds: bounds
        )
    }

    let finalVelocityY = simulation.state.cloud?.states[0].velocity.dy ?? 0

    // 終端速度を超えない
    #expect(finalVelocityY <= configuration.physics.terminalVelocity, "終端速度を超えないべき")
}

// MARK: - ブラックボックステスト（追加仕様）

@Test("フェードアウト: duration終了間際にopacityが減少する")
func fadeOutReducesOpacityNearEnd() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 2.0
    configuration.lifecycle.fadeOutDuration = 1.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 0
    configuration.wind.forceRange = 0 ... 0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(bounds: bounds, at: startTime, colorSource: ConstantColorSource(), using: &numberGenerator)

    // 中央に配置して境界外に出ないようにする
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 300)
        cloud.states[0].velocity = .zero
    }

    // フェードアウト開始前（1.0秒）
    simulation.seek(to: 0.5, bounds: bounds)
    let opacityBeforeFade = simulation.state.cloud?.states[0].opacity ?? 0

    // フェードアウト中（1.5秒 = duration - fadeOutDuration/2）
    simulation.seek(to: 1.5, bounds: bounds)
    let opacityDuringFade = simulation.state.cloud?.states[0].opacity ?? 0

    #expect(opacityBeforeFade == 1.0, "フェードアウト前はopacity=1.0")
    #expect(opacityDuringFade < 1.0, "フェードアウト中はopacity<1.0")
    #expect(opacityDuringFade > 0.0, "フェードアウト中はopacity>0.0")
}

@Test("シーク: 様々な時刻へのシークが正しく動作する", arguments: [0.0, 0.5, 1.0, 1.5, 2.0])
func seekToVariousTimes(targetTime: Double) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)
    simulation.seek(to: targetTime, bounds: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(min(targetTime, configuration.lifecycle.duration) / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime

    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("duration: 様々なduration値が正しく動作する", arguments: [1.0, 2.0, 3.0, 5.0, 10.0])
func durationVariousValues(duration: Double) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.duration = duration
    // Ensure fadeOutDuration doesn't exceed duration
    configuration.lifecycle.fadeOutDuration = min(1.0, duration * 0.3)

    let simulation = ConfettiSimulation(configuration: configuration)

    #expect(simulation.duration == duration)
}

// MARK: - seek範囲テスト（パラメタライズド）

@Test(
    "seek: 範囲外の値がクランプされる",
    arguments: [(-10.0, 0.0), (-1.0, 0.0), (5.0, 2.0), (100.0, 2.0)]
)
func seekClampsOutOfRangeValues(input: Double, expectedMax: Double) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 2.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    var simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(bounds: bounds, at: Date(), colorSource: ConstantColorSource(), using: &numberGenerator)
    simulation.seek(to: input, bounds: bounds)

    if input < 0 {
        #expect(simulation.currentTime >= 0, "負の入力は0以上にクランプされるべき")
    } else {
        #expect(simulation.currentTime <= expectedMax, "duration超過は\(expectedMax)以下にクランプされるべき")
    }
}
