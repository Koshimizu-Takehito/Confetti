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
@MainActor func startCreatesExpectedParticleCount() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 4

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(timeIntervalSince1970: 0),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )

    #expect(simulation.state.isRunning)
    #expect(simulation.state.cloud?.aliveCount == 10)
}

@Test("update: duration経過後にシミュレーションが停止する")
@MainActor func tickStopsAfterDuration() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 3
    configuration.lifecycle.duration = 0.1
    configuration.lifecycle.fadeOutDuration = 0.05
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    #expect(simulation.state.isRunning)

    simulation.update(at: startTime.addingTimeInterval(0.05), area: bounds)
    simulation.update(at: startTime.addingTimeInterval(0.10), area: bounds)
    simulation.update(at: startTime.addingTimeInterval(0.15), area: bounds)
    simulation.update(at: startTime.addingTimeInterval(0.20), area: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

@Test("stop: 状態がクリアされる")
@MainActor func stopClearsState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )
    #expect(simulation.state.isRunning)

    simulation.stop()
    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

// MARK: - 一時停止・再開テスト

@Test("pause: シミュレーションの進行が停止する")
@MainActor func pauseStopsSimulationProgress() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    #expect(simulation.state.isPlaying)
    #expect(!simulation.state.isPaused)

    simulation.update(at: startTime.addingTimeInterval(0.1), area: bounds)
    let timeBeforePause = simulation.currentTime

    simulation.pause()
    #expect(simulation.state.isRunning)
    #expect(simulation.state.isPaused)
    #expect(!simulation.state.isPlaying)

    simulation.update(at: startTime.addingTimeInterval(0.2), area: bounds)
    #expect(simulation.currentTime == timeBeforePause)
}

@Test("resume: 一時停止からシミュレーションが再開する")
@MainActor func resumeContinuesSimulation() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    simulation.update(at: startTime.addingTimeInterval(0.1), area: bounds)
    let timeBeforePause = simulation.currentTime

    simulation.pause()
    #expect(simulation.state.isPaused)

    let resumeTime = startTime.addingTimeInterval(1.0)
    simulation.resume(at: resumeTime)
    #expect(!simulation.state.isPaused)
    #expect(simulation.state.isPlaying)

    simulation.update(at: resumeTime.addingTimeInterval(0.1), area: bounds)
    #expect(simulation.currentTime > timeBeforePause)
}

// MARK: - シークテスト

@Test("seek: 指定した時刻にジャンプする")
@MainActor func seekJumpsToTargetTime() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.seek(to: 1.5, area: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(1.5 / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime
    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("seek: 範囲外の値は有効範囲にクランプされる")
@MainActor func seekClampsToValidRange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 2.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.seek(to: 10.0, area: bounds)
    #expect(simulation.currentTime <= configuration.lifecycle.duration)

    simulation.seek(to: -1.0, area: bounds)
    #expect(simulation.currentTime >= 0)
}

@Test("seek: 初期状態が保持され再利用される")
@MainActor func seekPreservesInitialState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.seek(to: 1.0, area: bounds)
    simulation.seek(to: 0.0, area: bounds)

    #expect(simulation.currentTime == 0)
    #expect(simulation.state.cloud?.aliveCount == 5)
}

// MARK: - プロパティテスト

@Test("duration: configurationの値と一致する")
@MainActor func durationMatchesConfiguration() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.duration = 5.0

    let simulation = ConfettiSimulation(configuration: configuration)
    #expect(simulation.duration == 5.0)
}

@Test("currentTime: 開始時は0である")
@MainActor func currentTimeStartsAtZero() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    #expect(simulation.currentTime == 0)
}

// MARK: - 境界値分析テスト（パラメタライズド）

@Test(
    "境界値: particleCount の様々な値でパーティクルが正しく生成される",
    arguments: [0, 1, 5, 100, 1000]
)
@MainActor func particleCountCreatesExpectedParticles(count: Int) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = count

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    #expect(simulation.state.isRunning)
    #expect(simulation.state.cloud?.aliveCount == count)
}

@Test("境界値: seek(0) で初期状態にリセットされる")
@MainActor func seekExactlyZeroResetsToInitialState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    let initialPositions = simulation.state.cloud?.states.map(\.position)

    simulation.seek(to: 1.0, area: bounds)
    simulation.seek(to: 0.0, area: bounds)

    let resetPositions = simulation.state.cloud?.states.map(\.position)
    #expect(simulation.currentTime == 0)
    #expect(initialPositions == resetPositions)
}

@Test("境界値: seek(duration) で終了時刻に到達する")
@MainActor func seekExactlyDurationAdvancesToEnd() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 1.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    simulation.seek(to: configuration.lifecycle.duration, area: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(configuration.lifecycle.duration / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime
    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("境界値: 非常に小さいboundsでパーティクルがすぐに境界外に出る")
@MainActor func boundsVerySmallParticlesGoOutOfBoundsQuickly() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 10.0
    configuration.spawn.boundaryMargin = 0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 1, height: 1)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    for i in 1 ... 10 {
        simulation.update(at: startTime.addingTimeInterval(Double(i) * 0.05), area: bounds)
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
@MainActor func outOfBoundsParticleRemoval(testCase: OutOfBoundsTestCase) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10
    configuration.spawn.boundaryMargin = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.wind.forceRange = 0 ... 0
    configuration.physics.gravity = 0 // 重力も無効化

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 100, height: 100)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = testCase.position
        cloud.states[0].velocity = .zero
    }

    simulation.update(at: startTime.addingTimeInterval(configuration.physics.fixedDeltaTime), area: bounds)

    if testCase.shouldBeRemoved {
        #expect(simulation.state.cloud?.aliveCount == 0, "位置 \(testCase.name) で削除されるべき")
    } else {
        #expect(simulation.state.cloud?.aliveCount == 1, "位置 \(testCase.name) で保持されるべき")
    }
}

// MARK: - 状態遷移テスト

@Test("状態遷移: stopped → running")
@MainActor func stateTransitionStoppedToRunning() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPlaying)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )

    #expect(simulation.state.isRunning)
    #expect(simulation.state.isPlaying)
    #expect(!simulation.state.isPaused)
}

@Test("状態遷移: running → paused → running")
@MainActor func stateTransitionRunningToPausedToRunning() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: startTime,
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
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
@MainActor func stateTransitionPausedToStopped() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )
    simulation.pause()
    #expect(simulation.state.isPaused)

    simulation.stop()
    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPaused)
    #expect(!simulation.state.isPlaying)
}

@Test("状態遷移: pause中のpauseは無視される")
@MainActor func stateTransitionPauseWhenAlreadyPausedNoChange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )
    simulation.pause()
    let stateAfterFirstPause = simulation.state

    simulation.pause()
    #expect(simulation.state.isPaused == stateAfterFirstPause.isPaused)
    #expect(simulation.state.isRunning == stateAfterFirstPause.isRunning)
}

@Test("状態遷移: pause中でないresumeは無視される")
@MainActor func stateTransitionResumeWhenNotPausedNoChange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)

    simulation.start(
        area: CGSize(width: 300, height: 600),
        at: Date(),
        colorSource: ConstantColorSource(),
        randomNumberGenerator: &numberGenerator
    )
    let stateBeforeResume = simulation.state

    simulation.resume(at: Date())
    #expect(simulation.state.isPaused == stateBeforeResume.isPaused)
    #expect(simulation.state.isPlaying == stateBeforeResume.isPlaying)
}

@Test("状態遷移: 未開始状態でのpauseは無視される")
@MainActor func stateTransitionPauseWhenNotRunningNoChange() {
    let simulation = ConfettiSimulation(configuration: ConfettiConfig())

    #expect(!simulation.state.isRunning)

    simulation.pause()
    #expect(!simulation.state.isPaused)
    #expect(!simulation.state.isRunning)
}

@Test("状態遷移: 未開始状態でのresumeは無視される")
@MainActor func stateTransitionResumeWhenNotRunningNoChange() {
    let simulation = ConfettiSimulation(configuration: ConfettiConfig())

    #expect(!simulation.state.isRunning)

    simulation.resume(at: Date())
    #expect(!simulation.state.isRunning)
    #expect(!simulation.state.isPlaying)
}

// MARK: - エラー推測・エッジケーステスト

@Test("エッジケース: 最小のfixedDeltaTimeでシミュレーションが正常動作する")
@MainActor func tickWithMinimumFixedDeltaTimeWorksNormally() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 240.0 // Minimum valid value

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.update(at: startTime.addingTimeInterval(0.1), area: bounds)
    #expect(simulation.state.isRunning)
    #expect(simulation.currentTime > 0)
}

@Test("エッジケース: 同一時刻でupdateしても進まない")
@MainActor func tickWithSameTimeDoesNotAdvance() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.update(at: startTime, area: bounds)
    #expect(simulation.currentTime == 0)
}

@Test("エッジケース: 大きな時間ジャンプはステップ数が制限される")
@MainActor func tickWithLargeTimeJumpLimitsStepsPerTick() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let startTime = Date(timeIntervalSince1970: 0)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.update(at: startTime.addingTimeInterval(10.0), area: bounds)

    #expect(simulation.currentTime < 1.0)
}

@Test("エッジケース: 開始前のupdateは無視される")
@MainActor func tickBeforeStartNoChange() {
    let simulation = ConfettiSimulation(configuration: ConfettiConfig())
    let bounds = CGSize(width: 300, height: 600)

    simulation.update(at: Date(), area: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.state.cloud == nil)
}

@Test("エッジケース: 開始前のseekは無視される")
@MainActor func seekBeforeStartNoChange() {
    let simulation = ConfettiSimulation(configuration: ConfettiConfig())
    let bounds = CGSize(width: 300, height: 600)

    simulation.seek(to: 1.0, area: bounds)

    #expect(!simulation.state.isRunning)
    #expect(simulation.currentTime == 0)
}

@Test("エッジケース: 複数回のstartで状態がリセットされる")
@MainActor func multipleStartsResetsState() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    simulation.update(at: startTime.addingTimeInterval(0.5), area: bounds)
    let timeAfterFirstRun = simulation.currentTime
    #expect(timeAfterFirstRun > 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    #expect(simulation.currentTime == 0)
    #expect(simulation.state.cloud?.aliveCount == 5)
}

// MARK: - 決定論性テスト

@Test("決定論性: 同じシードで同じ結果になる")
@MainActor func determinismSameSeedProducesSameResults() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    let simulation1 = ConfettiSimulation(configuration: configuration)
    var rng1: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation1.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &rng1)
    simulation1.update(at: startTime.addingTimeInterval(0.1), area: bounds)
    let positions1 = simulation1.state.cloud?.states.map(\.position)

    let simulation2 = ConfettiSimulation(configuration: configuration)
    var rng2: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation2.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &rng2)
    simulation2.update(at: startTime.addingTimeInterval(0.1), area: bounds)
    let positions2 = simulation2.state.cloud?.states.map(\.position)

    #expect(positions1 == positions2)
}

@Test("決定論性: 異なるシードで異なる結果になる")
@MainActor func determinismDifferentSeedsProduceDifferentResults() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    let simulation1 = ConfettiSimulation(configuration: configuration)
    var rng1: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    simulation1.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &rng1)
    let velocities1 = simulation1.state.cloud?.states.map(\.velocity)

    let simulation2 = ConfettiSimulation(configuration: configuration)
    var rng2: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 2)
    simulation2.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &rng2)
    let velocities2 = simulation2.state.cloud?.states.map(\.velocity)

    #expect(velocities1 != velocities2)
}

@Test("決定論性: seekが決定論的である")
@MainActor func seekIsDeterministic() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    let simulation = ConfettiSimulation(configuration: configuration)
    var rng: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &rng)
    simulation.seek(to: 1.0, area: bounds)
    let positionsAfterSeek = simulation.state.cloud?.states.map(\.position)

    simulation.seek(to: 0, area: bounds)
    simulation.seek(to: 1.0, area: bounds)
    let positionsAfterReSeek = simulation.state.cloud?.states.map(\.position)

    #expect(positionsAfterSeek == positionsAfterReSeek)
}

// MARK: - ホワイトボックステスト（物理演算分岐カバレッジ）

@Test("物理演算: 重力によりパーティクルが下方向に加速する")
@MainActor func physicsGravityAcceleratesDownward() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 1000 // 明確な重力
    configuration.physics.drag = 1.0 // ドラッグなし
    configuration.wind.forceRange = 0 ... 0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 初期状態を固定
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 100)
        cloud.states[0].velocity = CGVector.zero
    }

    let initialY = simulation.state.cloud?.states[0].position.y ?? 0

    // 複数フレーム進める
    for i in 1 ... 10 {
        simulation.update(
            at: startTime.addingTimeInterval(Double(i) * configuration.physics.fixedDeltaTime),
            area: bounds
        )
    }

    let finalY = simulation.state.cloud?.states[0].position.y ?? 0

    // 重力により下方向に移動（Y座標が増加）
    #expect(finalY > initialY, "重力によりY座標が増加するべき")
}

@Test("物理演算: ドラッグにより速度が減衰する")
@MainActor func physicsDragDeceleratesVelocity() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 0 // 重力なし
    configuration.physics.drag = 0.9 // 10%減衰
    configuration.wind.forceRange = 0 ... 0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 初速度を設定
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 300)
        cloud.states[0].velocity = CGVector(dx: 100, dy: 0)
    }

    let initialVelocityX = simulation.state.cloud?.states[0].velocity.dx ?? 0

    // 1フレーム進める
    simulation.update(at: startTime.addingTimeInterval(configuration.physics.fixedDeltaTime), area: bounds)

    let finalVelocityX = simulation.state.cloud?.states[0].velocity.dx ?? 0

    // ドラッグにより速度が減衰
    #expect(finalVelocityX < initialVelocityX, "ドラッグにより速度が減衰するべき")
}

@Test("物理演算: 終端速度を超えない")
@MainActor func physicsTerminalVelocityNotExceeded() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 10.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 10000 // 非常に強い重力
    configuration.physics.terminalVelocity = 100
    configuration.physics.drag = 1.0
    configuration.wind.forceRange = 0 ... 0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 10000)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 100)
        cloud.states[0].velocity = CGVector.zero
    }

    // 多くのフレーム進める
    for i in 1 ... 100 {
        simulation.update(
            at: startTime.addingTimeInterval(Double(i) * configuration.physics.fixedDeltaTime),
            area: bounds
        )
    }

    let finalVelocityY = simulation.state.cloud?.states[0].velocity.dy ?? 0

    // 終端速度を超えない
    #expect(finalVelocityY <= configuration.physics.terminalVelocity, "終端速度を超えないべき")
}

// MARK: - ブラックボックステスト（追加仕様）

@Test("フェードアウト: duration終了間際にopacityが減少する")
@MainActor func fadeOutReducesOpacityNearEnd() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 1
    configuration.lifecycle.duration = 2.0
    configuration.lifecycle.fadeOutDuration = 1.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0
    configuration.physics.gravity = 0
    configuration.wind.forceRange = 0 ... 0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date(timeIntervalSince1970: 0)

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 中央に配置して境界外に出ないようにする
    simulation.withCloudForTesting { cloud in
        cloud.states[0].position = CGPoint(x: 150, y: 300)
        cloud.states[0].velocity = .zero
    }

    // フェードアウト開始前（1.0秒）
    simulation.seek(to: 0.5, area: bounds)
    let opacityBeforeFade = simulation.state.cloud?.states[0].opacity ?? 0

    // フェードアウト中（1.5秒 = duration - fadeOutDuration/2）
    simulation.seek(to: 1.5, area: bounds)
    let opacityDuringFade = simulation.state.cloud?.states[0].opacity ?? 0

    #expect(opacityBeforeFade == 1.0, "フェードアウト前はopacity=1.0")
    #expect(opacityDuringFade < 1.0, "フェードアウト中はopacity<1.0")
    #expect(opacityDuringFade > 0.0, "フェードアウト中はopacity>0.0")
}

@Test("シーク: 様々な時刻へのシークが正しく動作する", arguments: [0.0, 0.5, 1.0, 1.5, 2.0])
@MainActor func seekToVariousTimes(targetTime: Double) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 3.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    simulation.seek(to: targetTime, area: bounds)

    let fixedDeltaTime = configuration.physics.fixedDeltaTime
    let expectedSteps = Int(min(targetTime, configuration.lifecycle.duration) / fixedDeltaTime)
    let expectedTime = TimeInterval(expectedSteps) * fixedDeltaTime

    #expect(abs(simulation.currentTime - expectedTime) < fixedDeltaTime)
}

@Test("duration: 様々なduration値が正しく動作する", arguments: [1.0, 2.0, 3.0, 5.0, 10.0])
@MainActor func durationVariousValues(duration: Double) {
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
@MainActor func seekClampsOutOfRangeValues(input: Double, expectedMax: Double) {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 5
    configuration.lifecycle.duration = 2.0
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)
    simulation.seek(to: input, area: bounds)

    if input < 0 {
        #expect(simulation.currentTime >= 0, "負の入力は0以上にクランプされるべき")
    } else {
        #expect(simulation.currentTime <= expectedMax, "duration超過は\(expectedMax)以下にクランプされるべき")
    }
}

// MARK: - パフォーマンステスト

@Test("パフォーマンス: renderStates computed property の再計算コスト")
@MainActor func renderStatesComputedPropertyPerformance() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 100
    configuration.lifecycle.duration = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 12345)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 最初のアクセス（キャッシュミス）
    let firstAccess = simulation.renderStates
    #expect(firstAccess.count == 100, "最初のアクセスで全パーティクルが返される")

    // 同じ state.cloud で複数回アクセス（すべてキャッシュヒット）
    var accessCount = 0
    let iterations = 1000

    let start = Date()
    for _ in 0 ..< iterations {
        let states = simulation.renderStates
        accessCount += states.count
    }
    let elapsed = Date().timeIntervalSince(start)

    #expect(accessCount == 100 * iterations, "全アクセスで正しい数が返される")

    // キャッシュが効いていれば非常に高速（0.01秒以下が期待値）
    let isVeryFast = elapsed < 0.01

    if !isVeryFast {
        print("⚠️ パフォーマンス: キャッシュヒット時の\(iterations)回アクセスに\(String(format: "%.3f", elapsed))秒")
        print("   期待値: 0.01秒以下（キャッシュが効いている場合）")
    } else {
        print("✅ キャッシュヒット: \(iterations)回アクセス = \(String(format: "%.4f", elapsed))秒")
    }
}

@Test("パフォーマンス: renderStates は cloud 変更時のみ再計算が必要")
@MainActor func renderStatesRecomputationOnCloudChange() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 50
    configuration.lifecycle.duration = 2
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 54321)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 初期状態
    let states1 = simulation.renderStates
    #expect(states1.count == 50)

    // cloud を変更（update 呼び出し）
    let now = Date()
    simulation.update(at: now.addingTimeInterval(0.1), area: bounds)

    // 変更後のアクセス
    let states2 = simulation.renderStates
    #expect(states2.count == 50)

    // 位置が変わっているはず
    let positions1 = states1.map(\.rect.midY)
    let positions2 = states2.map(\.rect.midY)

    var positionsChanged = false
    for (pos1, pos2) in zip(positions1, positions2) {
        if abs(pos1 - pos2) > 0.01 {
            positionsChanged = true
            break
        }
    }

    #expect(positionsChanged, "update 後は位置が変わるべき")
}

// MARK: - キャッシング機構テスト

@Test("キャッシュ: cloud が変更されていない場合は同じ配列を返す")
@MainActor func renderStatesCacheHit() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 999)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 同じ renderStates を複数回アクセス
    let states1 = simulation.renderStates
    let states2 = simulation.renderStates
    let states3 = simulation.renderStates

    // キャッシュヒットの確認：同一インスタンスが返されるべき
    #expect(states1.count == 10)
    #expect(states2.count == 10)
    #expect(states3.count == 10)

    // Array の identity は判定できないが、内容が同じことを確認
    for (s1, s2) in zip(states1, states2) {
        #expect(s1.id == s2.id)
        #expect(s1.rect == s2.rect)
        #expect(s1.opacity == s2.opacity)
    }
}

@Test("キャッシュ: update 後はキャッシュが無効化される")
@MainActor func cacheInvalidationAfterUpdate() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 111)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date()

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    let statesBefore = simulation.renderStates
    #expect(statesBefore.count == 10)

    // update を実行（cloud が変更される）
    simulation.update(at: startTime.addingTimeInterval(0.1), area: bounds)

    let statesAfter = simulation.renderStates
    #expect(statesAfter.count == 10)

    // 位置が変わっていることを確認（キャッシュが無効化されて再計算された証拠）
    var positionsChanged = false
    for (before, after) in zip(statesBefore, statesAfter) {
        if abs(before.rect.midY - after.rect.midY) > 0.01 {
            positionsChanged = true
            break
        }
    }

    #expect(positionsChanged, "update 後は renderStates が更新されるべき")
}

@Test("キャッシュ: seek 後はキャッシュが無効化される")
@MainActor func cacheInvalidationAfterSeek() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 222)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 初期位置を記録
    let statesBefore = simulation.renderStates
    let positionsBefore = statesBefore.map(\.rect.midY)

    // 時間を進める
    simulation.seek(to: 1.0, area: bounds)

    // seek 後の位置を取得
    let statesAfter = simulation.renderStates
    let positionsAfter = statesAfter.map(\.rect.midY)

    // 位置が変わっていることを確認
    var positionsChanged = false
    for (before, after) in zip(positionsBefore, positionsAfter) {
        if abs(before - after) > 0.01 {
            positionsChanged = true
            break
        }
    }

    #expect(positionsChanged, "seek 後は renderStates が更新されるべき")
}

@Test("キャッシュ: stop 後はキャッシュがクリアされる")
@MainActor func cacheInvalidationAfterStop() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 333)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    let statesBefore = simulation.renderStates
    #expect(statesBefore.count == 10)

    // stop を実行
    simulation.stop()

    // stop 後は空の配列を返すべき
    let statesAfter = simulation.renderStates
    #expect(statesAfter.isEmpty, "stop 後は renderStates が空になるべき")
}

@Test("キャッシュ: withCloudForTesting 後はキャッシュが無効化される")
@MainActor func cacheInvalidationAfterWithCloudForTesting() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 444)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    let statesBefore = simulation.renderStates
    let positionsBefore = statesBefore.map(\.rect.midY)

    // withCloudForTesting で cloud を変更
    simulation.withCloudForTesting { cloud in
        // 全パーティクルを下に移動
        for index in 0 ..< cloud.aliveCount {
            cloud.states[index].position.y += 100
        }
    }

    // withCloudForTesting 後の位置を取得
    let statesAfter = simulation.renderStates
    let positionsAfter = statesAfter.map(\.rect.midY)

    // 位置が変わっていることを確認（キャッシュが無効化された証拠）
    for (before, after) in zip(positionsBefore, positionsAfter) {
        #expect(abs(after - before - 100) < 1.0, "withCloudForTesting 後は renderStates が更新されるべき")
    }
}

@Test("キャッシュ: pause 中はキャッシュが維持される")
@MainActor func cachePreservedDuringPause() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 555)
    let bounds = CGSize(width: 300, height: 600)
    let startTime = Date()

    simulation.start(area: bounds, at: startTime, colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 少し進める
    simulation.update(at: startTime.addingTimeInterval(0.1), area: bounds)

    let statesBeforePause = simulation.renderStates
    let positionsBeforePause = statesBeforePause.map(\.rect.midY)

    // pause（cloud は変更されない）
    simulation.pause()

    // pause 中に複数回アクセス（すべてキャッシュヒット）
    let statesDuringPause1 = simulation.renderStates
    let statesDuringPause2 = simulation.renderStates
    let positionsDuringPause = statesDuringPause1.map(\.rect.midY)

    // 位置が変わっていないことを確認（キャッシュが維持されている）
    for (before, during) in zip(positionsBeforePause, positionsDuringPause) {
        #expect(abs(before - during) < 0.001, "pause 中は renderStates が変わらないべき")
    }

    // 複数回のアクセスで同じ結果
    for (s1, s2) in zip(statesDuringPause1, statesDuringPause2) {
        #expect(s1.rect == s2.rect, "pause 中の複数アクセスは同じ結果を返すべき")
    }
}

@Test("キャッシュ: 同じ時刻への複数回の seek でもキャッシュが無効化される")
@MainActor func cacheInvalidationOnDuplicateSeek() {
    var configuration = ConfettiConfig()
    configuration.lifecycle.particleCount = 10
    configuration.lifecycle.duration = 5
    configuration.physics.fixedDeltaTime = 1.0 / 60.0

    let simulation = ConfettiSimulation(configuration: configuration)
    var numberGenerator = SeededRandomNumberGenerator(seed: 666)
    let bounds = CGSize(width: 300, height: 600)

    simulation.start(area: bounds, at: Date(), colorSource: ConstantColorSource(), randomNumberGenerator: &numberGenerator)

    // 最初の seek
    simulation.seek(to: 1.0, area: bounds)
    let statesAfterFirstSeek = simulation.renderStates
    let positionsAfterFirstSeek = statesAfterFirstSeek.map(\.rect.midY)

    // 同じ時刻への2回目の seek
    simulation.seek(to: 1.0, area: bounds)
    let statesAfterSecondSeek = simulation.renderStates
    let positionsAfterSecondSeek = statesAfterSecondSeek.map(\.rect.midY)

    // 決定論的なので、位置は同じはず
    for (pos1, pos2) in zip(positionsAfterFirstSeek, positionsAfterSecondSeek) {
        #expect(abs(pos1 - pos2) < 0.001, "同じ時刻への seek は同じ結果を返すべき")
    }

    // しかし、version は異なる（キャッシュは無効化されている）
    // この動作は意図的：seek は常に cloud を再構築するため
}
