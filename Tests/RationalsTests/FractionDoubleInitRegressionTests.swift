import XCTest
@testable import Rationals

/// Regression tests for the infinite-recursion crash in Fraction.init(Double).
///
/// Some Swift compiler versions resolve `n < 0.0` (with n: Double) to the
/// heterogeneous `< (Double, Fraction)` operator instead of the stdlib
/// `< (Double, Double)`, converting the 0.0 literal to a Fraction via
/// Fraction(floatLiteral:) → Fraction(Double). When Fraction.init(Double)
/// itself contained such a comparison, every call recursed infinitely and
/// crashed with a stack overflow (seen in TestFlight builds of MathDown).
///
/// These tests exercise init(Double) and explicitly invoke the mixed-type
/// operators the compiler may substitute, so a reintroduced recursion or a
/// trap on scientific-notation doubles fails the suite on any toolchain.
final class FractionDoubleInitRegressionTests: XCTestCase {
    func testInitFromDouble() {
        XCTAssertEqual(Fraction(0.5), Fraction(num: 1, den: 2))
        XCTAssertEqual(Fraction(0.0), Fraction.zero)
        XCTAssertEqual(Fraction(2.0), Fraction(num: 2, den: 1))
        XCTAssertEqual(Fraction(-0.25), Fraction(num: -1, den: 4))
        XCTAssertEqual(Fraction(-3.0), Fraction(num: -3, den: 1))
    }

    func testInitFromNegativeZero() {
        let f = Fraction(-0.0)
        XCTAssertEqual(f.numerator, 0)
        XCTAssertEqual(f.signum, 0)
    }

    func testExplicitDoubleFractionComparisonOperators() {
        // Call the heterogeneous overloads directly — the same calls the
        // compiler may generate for `someDouble < 0.0` in client code.
        XCTAssertTrue(-1.5 < Fraction.zero)
        XCTAssertFalse(1.5 < Fraction.zero)
        XCTAssertTrue(Fraction.zero < 1.5)
        XCTAssertTrue(0.5 > Fraction.zero)
        XCTAssertTrue(Fraction(num: 1, den: 2) == 0.5)
        XCTAssertTrue(0.5 == Fraction(num: 1, den: 2))
        XCTAssertFalse(Fraction.one == 0.5)
    }

    func testComparisonOperatorsSafeForScientificNotationDoubles() {
        // Values that stringify in scientific notation ("1e-13") used to trap
        // inside Fraction(Double) when == routed through it.
        let tiny = 1e-13
        XCTAssertFalse(Fraction.one == tiny)
        XCTAssertFalse(tiny == Fraction.one)
        XCTAssertTrue(tiny < Fraction.one)
        XCTAssertTrue(Fraction.one > tiny)

        let huge = 1e20
        XCTAssertFalse(Fraction.one == huge)
        XCTAssertTrue(Fraction.one < huge)
    }

    func testFloatFractionEqualityOperators() {
        let half: Float = 0.5
        XCTAssertTrue(Fraction(num: 1, den: 2) == half)
        XCTAssertTrue(half == Fraction(num: 1, den: 2))
        XCTAssertFalse(Fraction.one == half)
    }
}
