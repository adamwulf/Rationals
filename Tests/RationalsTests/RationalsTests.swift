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
}
