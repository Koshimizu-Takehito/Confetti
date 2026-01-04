import CoreGraphics
import Testing

@testable import ConfettiCore

// MARK: - CGVectorArithmeticTests

@Suite("CGVector Arithmetic Extensions")
struct CGVectorArithmeticTests {
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
}

// MARK: - CGPointArithmeticTests

@Suite("CGPoint Arithmetic Extensions")
struct CGPointArithmeticTests {
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
