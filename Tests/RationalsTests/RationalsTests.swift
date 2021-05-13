import XCTest
@testable import Rationals

final class RationalsTests: XCTestCase {
    func testGCD() {
        XCTAssertEqual(gcd(6, 10), 2)
        XCTAssertEqual(gcd(13, 10), 1)
        XCTAssertEqual(gcd(7, 10), 1)
        XCTAssertEqual(gcd(21, 91), 7)
    }

    func testLCM() {
        XCTAssertEqual(lcm(5, 10), 10)
        XCTAssertEqual(lcm(6, 10), 30)
        XCTAssertEqual(lcm(13, 10), 130)
        XCTAssertEqual(lcm(7, 10), 70)
        XCTAssertEqual(lcm(21, 91), 273)
    }

    func testReduce() {
        XCTAssertEqual(reduce(numerator: 10, denominator: 0).numerator, 1)
        XCTAssertEqual(reduce(numerator: 10, denominator: 0).denominator, 0)

        XCTAssertEqual(reduce(numerator: 0, denominator: 10).numerator, 0)
        XCTAssertEqual(reduce(numerator: 0, denominator: 10).denominator, 1)

        XCTAssertEqual(reduce(numerator: 10, denominator: 10).numerator, 1)
        XCTAssertEqual(reduce(numerator: 10, denominator: 10).denominator, 1)

        XCTAssertEqual(reduce(numerator: 0, denominator: 0).numerator, 0)
        XCTAssertEqual(reduce(numerator: 0, denominator: 0).denominator, 0)

        XCTAssertEqual(reduce(numerator: 0, denominator: 0).numerator, 0)
        XCTAssertEqual(reduce(numerator: 0, denominator: 0).denominator, 0)

        XCTAssertEqual(reduce(numerator: 123, denominator: 72).numerator, 41)
        XCTAssertEqual(reduce(numerator: 123, denominator: 72).denominator, 24)

        XCTAssertEqual(Fraction(123, 72), Fraction(41, 24))
    }

    func testSign() {
        var foo: Fraction = 1 / 3
        XCTAssertEqual(foo.numerator, 1)
        XCTAssertEqual(foo.denominator, 3)
        XCTAssertEqual(foo.signum, 1)

        foo.negate()

        XCTAssertEqual(foo.numerator, -1)
        XCTAssertEqual(foo.denominator, 3)
        XCTAssertEqual(foo.signum, -1)

        foo = 7 / -3

        XCTAssertEqual(foo.numerator, -7)
        XCTAssertEqual(foo.denominator, 3)
        XCTAssertEqual(foo.signum, -1)

        foo.negate()

        XCTAssertEqual(foo.numerator, 7)
        XCTAssertEqual(foo.denominator, 3)
        XCTAssertEqual(foo.signum, 1)

        foo = 7 / 0

        XCTAssertEqual(foo.numerator, 1)
        XCTAssertEqual(foo.denominator, 0)
        XCTAssertEqual(foo.signum, 1)

        foo = -7 / 0

        XCTAssertEqual(foo.numerator, -1)
        XCTAssertEqual(foo.denominator, 0)
        XCTAssertEqual(foo.signum, -1)

        foo = 0 / 0

        XCTAssertEqual(foo.numerator, 0)
        XCTAssertEqual(foo.denominator, 0)
        XCTAssertEqual(foo.signum, 0)
    }

    func testIs() {
        var foo: Fraction = 1 / 3

        XCTAssertTrue(foo.isFinite)
        XCTAssertFalse(foo.isInfinite)
        XCTAssertFalse(foo.isNaN)
        XCTAssertFalse(foo.isWholeNumber)

        foo = 7 / 0

        XCTAssertFalse(foo.isFinite)
        XCTAssertTrue(foo.isInfinite)
        XCTAssertFalse(foo.isNaN)
        XCTAssertFalse(foo.isWholeNumber)

        foo = -7 / 0

        XCTAssertFalse(foo.isFinite)
        XCTAssertTrue(foo.isInfinite)
        XCTAssertFalse(foo.isNaN)
        XCTAssertFalse(foo.isWholeNumber)

        foo = 0 / 0

        XCTAssertFalse(foo.isFinite)
        XCTAssertFalse(foo.isInfinite)
        XCTAssertTrue(foo.isNaN)
        XCTAssertFalse(foo.isWholeNumber)

        foo = 3 / 1

        XCTAssertTrue(foo.isFinite)
        XCTAssertFalse(foo.isInfinite)
        XCTAssertFalse(foo.isNaN)
        XCTAssertTrue(foo.isWholeNumber)

        foo = 6 / 2

        XCTAssertTrue(foo.isFinite)
        XCTAssertFalse(foo.isInfinite)
        XCTAssertFalse(foo.isNaN)
        XCTAssertTrue(foo.isWholeNumber)
    }

    func testDistance() {
        var start: Fraction = 1 / 2
        var end: Fraction = 2 / 3

        XCTAssertEqual(start.distance(to: end), 1 / 6)
        XCTAssertEqual(end.distance(to: start), -1 / 6)

        start = 1 / 0
        end = 2 / 3

        XCTAssertEqual(start.distance(to: end), -Fraction.infinity)
        XCTAssertEqual(end.distance(to: start), Fraction.infinity)

        start = 0 / 0
        end = 2 / 3

        XCTAssertEqual(start.distance(to: end), Fraction.NaN)
        XCTAssertEqual(end.distance(to: start), Fraction.NaN)
    }

    func testAverage() {
        var start: Fraction = 1 / 2
        var end: Fraction = 2 / 3

        XCTAssertEqual((start + end) / 2, 7 / 12)

        start = 1.0 / 2.0
        end = 2.0 / 3.0

        XCTAssertEqual((start + end) / 2, 7 / 12)
    }

    func testEqual() {
        XCTAssertFalse(Fraction(1, 3) == Float(1.0 / 3.0))
        XCTAssertFalse(Float(1.0 / 3.0) == Fraction(1, 3))

        XCTAssertFalse(Fraction(1, 3) == Double(1.0 / 3.0))
        XCTAssertFalse(Double(1.0 / 3.0) == Fraction(1, 3))
    }

    func testLargeNumbers() {
        let third: Fraction = Fraction(1.0 / 3.0)
        let thirteenth: Fraction = Fraction(7.0 / 13.0)

        XCTAssertEqual(third, 3333333333333333 / 10000000000000000)
        XCTAssertEqual(thirteenth, 673076923076923 / 1250000000000000)
        XCTAssertEqual(third + thirteenth, 8717948717948717 / 10000000000000000)
        XCTAssertEqual(third - thirteenth, -2051282051282051 / 10000000000000000)
    }

    func testOverflow() {
        let third: Fraction = Fraction(1.0 / 3.0)
        let thirteenth: Fraction = Fraction(7.0 / 13.0)

        XCTAssertEqual(third, 3333333333333333 / 10000000000000000)
        XCTAssertEqual(thirteenth, 673076923076923 / 1250000000000000)
        XCTAssertEqual(third + thirteenth, 8717948717948717 / 10000000000000000)
        XCTAssertEqual(third - thirteenth, -2051282051282051 / 10000000000000000)
    }
}
