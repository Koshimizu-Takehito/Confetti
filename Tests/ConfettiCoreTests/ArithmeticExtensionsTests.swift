import CoreGraphics
import Testing

@testable import ConfettiCore

// MARK: - CGSizeArithmeticTests

@Suite("CGSize Arithmetic Extensions")
struct CGSizeArithmeticTests {
    // MARK: - Initialization

    @Test("初期化: スカラー値から同じ成分のCGSizeを生成")
    func sizeFromScalar() {
        let size = CGSize(scalar: 10.0)

        #expect(size.width == 10.0)
        #expect(size.height == 10.0)
    }

    // MARK: - Scalar Multiplication

    @Test("スカラー乗算: サイズ * スカラー")
    func sizeScalarMultiplication() {
        let size = CGSize(width: 20.0, height: 10.0)
        let result = size * 2.0

        #expect(result.width == 40.0)
        #expect(result.height == 20.0)
    }

    @Test("スカラー乗算: スカラー * サイズ (可換)")
    func scalarSizeMultiplication() {
        let size = CGSize(width: 20.0, height: 10.0)
        let result = 2.0 * size

        #expect(result.width == 40.0)
        #expect(result.height == 20.0)
    }

    @Test("スカラー乗算代入: サイズにスカラーを乗算")
    func sizeScalarMultiplicationAssignment() {
        var size = CGSize(width: 20.0, height: 10.0)
        size *= 2.0

        #expect(size.width == 40.0)
        #expect(size.height == 20.0)
    }

    @Test("スカラー乗算: 深度スケールの適用")
    func sizeDepthScaling() {
        let originalSize = CGSize(width: 30.0, height: 15.0)
        let depthScale = 0.75

        let scaledSize = originalSize * depthScale

        #expect(scaledSize.width == 22.5)
        #expect(scaledSize.height == 11.25)
    }

    @Test("スカラー乗算: ゼロとの乗算")
    func sizeScalarMultiplicationWithZero() {
        let size = CGSize(width: 20.0, height: 10.0)
        let result = size * 0.0

        #expect(result.width == 0.0)
        #expect(result.height == 0.0)
    }

    // MARK: - Scalar Division

    @Test("スカラー除算: サイズ / スカラー")
    func sizeScalarDivision() {
        let size = CGSize(width: 40.0, height: 20.0)
        let result = size / 2.0

        #expect(result.width == 20.0)
        #expect(result.height == 10.0)
    }

    @Test("スカラー除算代入: サイズをスカラーで除算")
    func sizeScalarDivisionAssignment() {
        var size = CGSize(width: 40.0, height: 20.0)
        size /= 2.0

        #expect(size.width == 20.0)
        #expect(size.height == 10.0)
    }

    @Test("スカラー除算: 負のスカラーでの除算")
    func sizeScalarDivisionWithNegative() {
        let size = CGSize(width: 40.0, height: 20.0)
        let result = size / -2.0

        #expect(result.width == -20.0)
        #expect(result.height == -10.0)
    }
}

// MARK: - CGVectorArithmeticTests

@Suite("CGVector Arithmetic Extensions")
struct CGVectorArithmeticTests {
    // MARK: - Initialization & Conversion

    @Test("初期化: CGPointからCGVectorを生成")
    func vectorFromPoint() {
        let point = CGPoint(x: 3.0, y: 4.0)
        let vector = CGVector(point)

        #expect(vector.dx == 3.0)
        #expect(vector.dy == 4.0)
    }

    @Test("初期化: スカラー値から同じ成分のCGVectorを生成")
    func vectorFromScalar() {
        let vector = CGVector(scalar: 5.0)

        #expect(vector.dx == 5.0)
        #expect(vector.dy == 5.0)
    }

    @Test("変換: CGVectorをCGPointに変換")
    func vectorToPoint() {
        let vector = CGVector(dx: 7.0, dy: 9.0)
        let point = vector.cgPoint

        #expect(point.x == 7.0)
        #expect(point.y == 9.0)
    }

    @Test("変換: CGVector → CGPoint → CGVectorの往復変換")
    func vectorRoundTrip() {
        let original = CGVector(dx: 12.5, dy: -8.3)
        let point = original.cgPoint
        let restored = CGVector(point)

        #expect(restored.dx == original.dx)
        #expect(restored.dy == original.dy)
    }

    // MARK: - Addition

    @Test("加算: 2つのベクトルの成分ごとの加算")
    func vectorAddition() {
        let v1 = CGVector(dx: 1.0, dy: 2.0)
        let v2 = CGVector(dx: 3.0, dy: 4.0)
        let result = v1 + v2

        #expect(result.dx == 4.0)
        #expect(result.dy == 6.0)
    }

    @Test("加算代入: ベクトルに別のベクトルを加算")
    func vectorAdditionAssignment() {
        var v1 = CGVector(dx: 1.0, dy: 2.0)
        let v2 = CGVector(dx: 3.0, dy: 4.0)
        v1 += v2

        #expect(v1.dx == 4.0)
        #expect(v1.dy == 6.0)
    }

    @Test("加算: ゼロベクトルとの加算")
    func vectorAdditionWithZero() {
        let v = CGVector(dx: 5.0, dy: 7.0)
        let zero = CGVector(dx: 0.0, dy: 0.0)
        let result = v + zero

        #expect(result.dx == 5.0)
        #expect(result.dy == 7.0)
    }

    @Test("加算: 負の値を持つベクトルの加算")
    func vectorAdditionWithNegative() {
        let v1 = CGVector(dx: 5.0, dy: -3.0)
        let v2 = CGVector(dx: -2.0, dy: 7.0)
        let result = v1 + v2

        #expect(result.dx == 3.0)
        #expect(result.dy == 4.0)
    }

    // MARK: - Subtraction

    @Test("減算: 2つのベクトルの成分ごとの減算")
    func vectorSubtraction() {
        let v1 = CGVector(dx: 5.0, dy: 7.0)
        let v2 = CGVector(dx: 2.0, dy: 3.0)
        let result = v1 - v2

        #expect(result.dx == 3.0)
        #expect(result.dy == 4.0)
    }

    @Test("減算代入: ベクトルから別のベクトルを減算")
    func vectorSubtractionAssignment() {
        var v1 = CGVector(dx: 5.0, dy: 7.0)
        let v2 = CGVector(dx: 2.0, dy: 3.0)
        v1 -= v2

        #expect(v1.dx == 3.0)
        #expect(v1.dy == 4.0)
    }

    @Test("減算: ゼロベクトルとの減算")
    func vectorSubtractionWithZero() {
        let v = CGVector(dx: 5.0, dy: 7.0)
        let zero = CGVector(dx: 0.0, dy: 0.0)
        let result = v - zero

        #expect(result.dx == 5.0)
        #expect(result.dy == 7.0)
    }

    // MARK: - Scalar Multiplication

    @Test("スカラー乗算: ベクトル * スカラー")
    func vectorScalarMultiplication() {
        let v = CGVector(dx: 2.0, dy: 3.0)
        let result = v * 4.0

        #expect(result.dx == 8.0)
        #expect(result.dy == 12.0)
    }

    @Test("スカラー乗算: スカラー * ベクトル (可換)")
    func scalarVectorMultiplication() {
        let v = CGVector(dx: 2.0, dy: 3.0)
        let result = 4.0 * v

        #expect(result.dx == 8.0)
        #expect(result.dy == 12.0)
    }

    @Test("スカラー乗算代入: ベクトルにスカラーを乗算")
    func vectorScalarMultiplicationAssignment() {
        var v = CGVector(dx: 2.0, dy: 3.0)
        v *= 4.0

        #expect(v.dx == 8.0)
        #expect(v.dy == 12.0)
    }

    @Test("スカラー乗算: ゼロとの乗算")
    func vectorScalarMultiplicationWithZero() {
        let v = CGVector(dx: 5.0, dy: 7.0)
        let result = v * 0.0

        #expect(result.dx == 0.0)
        #expect(result.dy == 0.0)
    }

    @Test("スカラー乗算: 負のスカラーとの乗算")
    func vectorScalarMultiplicationWithNegative() {
        let v = CGVector(dx: 2.0, dy: -3.0)
        let result = v * -2.0

        #expect(result.dx == -4.0)
        #expect(result.dy == 6.0)
    }

    @Test("スカラー乗算: 小数との乗算")
    func vectorScalarMultiplicationWithFraction() {
        let v = CGVector(dx: 10.0, dy: 20.0)
        let result = v * 0.5

        #expect(result.dx == 5.0)
        #expect(result.dy == 10.0)
    }

    // MARK: - Scalar Division

    @Test("スカラー除算: ベクトル / スカラー")
    func vectorScalarDivision() {
        let v = CGVector(dx: 8.0, dy: 12.0)
        let result = v / 4.0

        #expect(result.dx == 2.0)
        #expect(result.dy == 3.0)
    }

    @Test("スカラー除算代入: ベクトルをスカラーで除算")
    func vectorScalarDivisionAssignment() {
        var v = CGVector(dx: 8.0, dy: 12.0)
        v /= 4.0

        #expect(v.dx == 2.0)
        #expect(v.dy == 3.0)
    }

    @Test("スカラー除算: 負のスカラーでの除算")
    func vectorScalarDivisionWithNegative() {
        let v = CGVector(dx: 8.0, dy: -12.0)
        let result = v / -2.0

        #expect(result.dx == -4.0)
        #expect(result.dy == 6.0)
    }

    // MARK: - Combined Operations

    @Test("複合演算: 複数の演算の組み合わせ")
    func vectorCombinedOperations() {
        let v1 = CGVector(dx: 2.0, dy: 3.0)
        let v2 = CGVector(dx: 4.0, dy: 5.0)
        let result = (v1 + v2) * 2.0 - CGVector(dx: 2.0, dy: 2.0)

        #expect(result.dx == 10.0) // (2+4)*2 - 2 = 10
        #expect(result.dy == 14.0) // (3+5)*2 - 2 = 14
    }

    @Test("複合演算: 物理シミュレーション風の計算")
    func vectorPhysicsSimulation() {
        var velocity = CGVector(dx: 10.0, dy: 20.0)
        let acceleration = CGVector(dx: 2.0, dy: -5.0)
        let deltaTime = 0.5

        // velocity += acceleration * deltaTime
        velocity += acceleration * deltaTime

        #expect(velocity.dx == 11.0) // 10 + 2*0.5
        #expect(velocity.dy == 17.5) // 20 + (-5)*0.5
    }

    @Test("変換: 速度ベクトルから位置の変化を計算")
    func vectorToPositionDelta() {
        let velocity = CGVector(dx: 10.0, dy: -5.0)
        let deltaTime = 0.5

        // Convert velocity * deltaTime to position delta
        let delta = CGPoint(velocity * deltaTime)

        #expect(delta.x == 5.0) // 10 * 0.5
        #expect(delta.y == -2.5) // -5 * 0.5
    }

    // MARK: - Geometric Operations

    @Test("幾何演算: ベクトルの成分を入れ替え")
    func vectorSwapped() {
        let vector = CGVector(dx: 3.0, dy: 7.0)
        let swapped = vector.swapped

        #expect(swapped.dx == 7.0)
        #expect(swapped.dy == 3.0)
    }

    @Test("幾何演算: 成分ごとの乗算 (Hadamard積)")
    func vectorHadamardProduct() {
        let v1 = CGVector(dx: 2.0, dy: 3.0)
        let v2 = CGVector(dx: 4.0, dy: 5.0)
        let result = v1.hadamard(v2)

        #expect(result.dx == 8.0) // 2 * 4
        #expect(result.dy == 15.0) // 3 * 5
    }

    @Test("幾何演算: 回転計算での速度効果")
    func vectorRotationEffect() {
        let velocity = CGVector(dx: 10.0, dy: 20.0)
        let rotationCoeff = CGVector(dx: 0.01, dy: 0.008)

        // Velocity influence (swapped and component-wise)
        let effect = velocity.swapped.hadamard(rotationCoeff)

        #expect(effect.dx == 0.2) // 20 * 0.01
        #expect(effect.dy == 0.08) // 10 * 0.008
    }
}

// MARK: - CGPointArithmeticTests

@Suite("CGPoint Arithmetic Extensions")
struct CGPointArithmeticTests {
    // MARK: - Initialization & Conversion

    @Test("初期化: CGVectorからCGPointを生成")
    func pointFromVector() {
        let vector = CGVector(dx: 3.0, dy: 4.0)
        let point = CGPoint(vector)

        #expect(point.x == 3.0)
        #expect(point.y == 4.0)
    }

    @Test("初期化: スカラー値から同じ成分のCGPointを生成")
    func pointFromScalar() {
        let point = CGPoint(scalar: 5.0)

        #expect(point.x == 5.0)
        #expect(point.y == 5.0)
    }

    @Test("変換: CGPointをCGVectorに変換")
    func pointToVector() {
        let point = CGPoint(x: 7.0, y: 9.0)
        let vector = point.cgVector

        #expect(vector.dx == 7.0)
        #expect(vector.dy == 9.0)
    }

    @Test("変換: CGPoint → CGVector → CGPointの往復変換")
    func pointRoundTrip() {
        let original = CGPoint(x: 12.5, y: -8.3)
        let vector = original.cgVector
        let restored = CGPoint(vector)

        #expect(restored.x == original.x)
        #expect(restored.y == original.y)
    }

    // MARK: - Addition

    @Test("加算: 2つのポイントの成分ごとの加算")
    func pointAddition() {
        let p1 = CGPoint(x: 1.0, y: 2.0)
        let p2 = CGPoint(x: 3.0, y: 4.0)
        let result = p1 + p2

        #expect(result.x == 4.0)
        #expect(result.y == 6.0)
    }

    @Test("加算代入: ポイントに別のポイントを加算")
    func pointAdditionAssignment() {
        var p1 = CGPoint(x: 1.0, y: 2.0)
        let p2 = CGPoint(x: 3.0, y: 4.0)
        p1 += p2

        #expect(p1.x == 4.0)
        #expect(p1.y == 6.0)
    }

    @Test("加算: ゼロポイントとの加算")
    func pointAdditionWithZero() {
        let p = CGPoint(x: 5.0, y: 7.0)
        let zero = CGPoint(x: 0.0, y: 0.0)
        let result = p + zero

        #expect(result.x == 5.0)
        #expect(result.y == 7.0)
    }

    @Test("加算: 負の値を持つポイントの加算")
    func pointAdditionWithNegative() {
        let p1 = CGPoint(x: 5.0, y: -3.0)
        let p2 = CGPoint(x: -2.0, y: 7.0)
        let result = p1 + p2

        #expect(result.x == 3.0)
        #expect(result.y == 4.0)
    }

    // MARK: - Subtraction

    @Test("減算: 2つのポイントの成分ごとの減算")
    func pointSubtraction() {
        let p1 = CGPoint(x: 5.0, y: 7.0)
        let p2 = CGPoint(x: 2.0, y: 3.0)
        let result = p1 - p2

        #expect(result.x == 3.0)
        #expect(result.y == 4.0)
    }

    @Test("減算代入: ポイントから別のポイントを減算")
    func pointSubtractionAssignment() {
        var p1 = CGPoint(x: 5.0, y: 7.0)
        let p2 = CGPoint(x: 2.0, y: 3.0)
        p1 -= p2

        #expect(p1.x == 3.0)
        #expect(p1.y == 4.0)
    }

    @Test("減算: ベクトルの差分計算")
    func pointSubtractionAsVectorDifference() {
        let start = CGPoint(x: 10.0, y: 20.0)
        let end = CGPoint(x: 15.0, y: 25.0)
        let delta = end - start

        #expect(delta.x == 5.0)
        #expect(delta.y == 5.0)
    }

    // MARK: - Scalar Multiplication

    @Test("スカラー乗算: ポイント * スカラー")
    func pointScalarMultiplication() {
        let p = CGPoint(x: 2.0, y: 3.0)
        let result = p * 4.0

        #expect(result.x == 8.0)
        #expect(result.y == 12.0)
    }

    @Test("スカラー乗算: スカラー * ポイント (可換)")
    func scalarPointMultiplication() {
        let p = CGPoint(x: 2.0, y: 3.0)
        let result = 4.0 * p

        #expect(result.x == 8.0)
        #expect(result.y == 12.0)
    }

    @Test("スカラー乗算代入: ポイントにスカラーを乗算")
    func pointScalarMultiplicationAssignment() {
        var p = CGPoint(x: 2.0, y: 3.0)
        p *= 4.0

        #expect(p.x == 8.0)
        #expect(p.y == 12.0)
    }

    @Test("スカラー乗算: ゼロとの乗算")
    func pointScalarMultiplicationWithZero() {
        let p = CGPoint(x: 5.0, y: 7.0)
        let result = p * 0.0

        #expect(result.x == 0.0)
        #expect(result.y == 0.0)
    }

    @Test("スカラー乗算: 負のスカラーとの乗算")
    func pointScalarMultiplicationWithNegative() {
        let p = CGPoint(x: 2.0, y: -3.0)
        let result = p * -2.0

        #expect(result.x == -4.0)
        #expect(result.y == 6.0)
    }

    // MARK: - Scalar Division

    @Test("スカラー除算: ポイント / スカラー")
    func pointScalarDivision() {
        let p = CGPoint(x: 8.0, y: 12.0)
        let result = p / 4.0

        #expect(result.x == 2.0)
        #expect(result.y == 3.0)
    }

    @Test("スカラー除算代入: ポイントをスカラーで除算")
    func pointScalarDivisionAssignment() {
        var p = CGPoint(x: 8.0, y: 12.0)
        p /= 4.0

        #expect(p.x == 2.0)
        #expect(p.y == 3.0)
    }

    @Test("スカラー除算: 負のスカラーでの除算")
    func pointScalarDivisionWithNegative() {
        let p = CGPoint(x: 8.0, y: -12.0)
        let result = p / -2.0

        #expect(result.x == -4.0)
        #expect(result.y == 6.0)
    }

    // MARK: - Combined Operations

    @Test("複合演算: 複数の演算の組み合わせ")
    func pointCombinedOperations() {
        let p1 = CGPoint(x: 2.0, y: 3.0)
        let p2 = CGPoint(x: 4.0, y: 5.0)
        let result = (p1 + p2) * 2.0 - CGPoint(x: 2.0, y: 2.0)

        #expect(result.x == 10.0) // (2+4)*2 - 2 = 10
        #expect(result.y == 14.0) // (3+5)*2 - 2 = 14
    }

    @Test("複合演算: 位置更新の計算")
    func pointPositionUpdate() {
        var position = CGPoint(x: 100.0, y: 200.0)
        let velocity = CGPoint(x: 10.0, y: -5.0)
        let deltaTime = 0.5

        // position += velocity * deltaTime
        position += velocity * deltaTime

        #expect(position.x == 105.0) // 100 + 10*0.5
        #expect(position.y == 197.5) // 200 + (-5)*0.5
    }

    @Test("複合演算: 中点の計算")
    func pointMidpointCalculation() {
        let start = CGPoint(x: 0.0, y: 0.0)
        let end = CGPoint(x: 10.0, y: 20.0)
        let midpoint = (start + end) / 2.0

        #expect(midpoint.x == 5.0)
        #expect(midpoint.y == 10.0)
    }

    @Test("複合演算: 線形補間 (lerp)")
    func pointLinearInterpolation() {
        let start = CGPoint(x: 0.0, y: 0.0)
        let end = CGPoint(x: 100.0, y: 200.0)
        let t = 0.3

        // lerp = start + (end - start) * t
        let result = start + (end - start) * t

        #expect(result.x == 30.0) // 0 + (100-0)*0.3
        #expect(result.y == 60.0) // 0 + (200-0)*0.3
    }
}

// MARK: - CGRectUtilitiesTests

@Suite("CGRect Utility Extensions")
struct CGRectUtilitiesTests {
    @Test("境界判定: マージンなしで矩形内のポイント")
    func containsPointWithoutMargin() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: 50, y: 50)

        #expect(rect.contains(point, margin: 0))
    }

    @Test("境界判定: 正のマージンで拡張された矩形")
    func containsPointWithPositiveMargin() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: -5, y: 50) // Outside without margin

        #expect(rect.contains(point, margin: 10)) // Inside with margin
    }

    @Test("境界判定: 負のマージンで縮小された矩形")
    func containsPointWithNegativeMargin() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: 5, y: 5) // Inside without margin

        #expect(!rect.contains(point, margin: -10)) // Outside with negative margin
    }

    @Test("境界判定: 矩形外のポイント")
    func pointOutsideRectangle() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: 150, y: 50)

        #expect(!rect.contains(point, margin: 0))
        #expect(!rect.contains(point, margin: 10))
    }

    @Test("境界判定: 境界上のポイント")
    func pointOnBoundary() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: 100, y: 100) // Exactly on max boundary (exclusive, so outside)

        // CGRect treats max bounds as exclusive, so (100, 100) is outside
        #expect(!rect.contains(point, margin: 0))
        // But with positive margin, it becomes inside
        #expect(rect.contains(point, margin: 1))
    }

    @Test("境界判定: シミュレーション領域の境界チェック")
    func simulationBoundsCheck() {
        let simulationRect = CGRect(origin: .zero, size: CGSize(width: 200, height: 300))
        let margin: CGFloat = 10

        // Point just outside without margin, inside with margin
        let edgePoint = CGPoint(x: -5, y: 150)
        #expect(simulationRect.contains(edgePoint, margin: margin))

        // Point far outside
        let outsidePoint = CGPoint(x: -20, y: 150)
        #expect(!simulationRect.contains(outsidePoint, margin: margin))
    }
}

// MARK: - DoubleUtilitiesTests

@Suite("Double Utility Extensions")
struct DoubleUtilitiesTests {
    @Test("線形補間: 中間値への補間")
    func lerpToMiddle() {
        let start = 0.0
        let result = start.lerp(to: 100.0, t: 0.5)

        #expect(result == 50.0)
    }

    @Test("線形補間: 開始値 (t=0)")
    func lerpAtStart() {
        let start = 10.0
        let result = start.lerp(to: 20.0, t: 0.0)

        #expect(result == 10.0)
    }

    @Test("線形補間: 終了値 (t=1)")
    func lerpAtEnd() {
        let start = 10.0
        let result = start.lerp(to: 20.0, t: 1.0)

        #expect(result == 20.0)
    }

    @Test("線形補間: フェードアウト効果")
    func lerpFadeOut() {
        let opacity = 1.0
        let fadeProgress = 0.3

        let result = opacity.lerp(to: 0.0, t: fadeProgress)

        #expect(result == 0.7)
    }

    @Test("クランプ: 範囲内の値")
    func clampedWithinRange() {
        let value = 0.5
        let result = value.clamped(to: 0 ... 1)

        #expect(result == 0.5)
    }

    @Test("クランプ: 下限を超える値")
    func clampedBelowRange() {
        let value = -0.5
        let result = value.clamped(to: 0 ... 1)

        #expect(result == 0.0)
    }

    @Test("クランプ: 上限を超える値")
    func clampedAboveRange() {
        let value = 1.5
        let result = value.clamped(to: 0 ... 1)

        #expect(result == 1.0)
    }

    @Test("クランプ: 境界値")
    func clampedOnBoundary() {
        #expect(0.0.clamped(to: 0 ... 1) == 0.0)
        #expect(1.0.clamped(to: 0 ... 1) == 1.0)
    }

    @Test("複合: フェードアウトの線形補間とクランプ")
    func lerpAndClampCombined() {
        let opacity = 1.0
        let fadeProgress = 1.2 // Over 100%

        let result = opacity.lerp(to: 0.0, t: fadeProgress).clamped(to: 0 ... 1)

        #expect(result == 0.0) // Clamped to 0
    }
}
