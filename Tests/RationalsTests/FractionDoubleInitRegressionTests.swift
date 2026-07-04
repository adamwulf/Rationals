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

    // MARK: - Total init(_ n: Double)

    /// init(_ n: Double) is total: NaN and the infinities map to the
    /// corresponding non-finite Fractions instead of trapping.
    func testInitFromNonFiniteDoubles() {
        XCTAssertTrue(Fraction(Double.nan).isNaN)

        let inf = Fraction(Double.infinity)
        XCTAssertTrue(inf.isInfinite)
        XCTAssertEqual(inf.signum, 1)

        let negInf = Fraction(-Double.infinity)
        XCTAssertTrue(negInf.isInfinite)
        XCTAssertEqual(negInf.signum, -1)
    }

    /// Finite values whose textual form is scientific notation used to trap in
    /// the old string-parsing init. They must now convert without crashing.
    /// A magnitude below the approximation epsilon collapses to zero.
    func testInitFromScientificNotationDoubles() {
        XCTAssertEqual(Fraction(1e-13), Fraction.zero)
        XCTAssertEqual(Fraction(-1e-13), Fraction.zero)

        // 1e20 exceeds Int.max, so it saturates to the closest Int-backed value
        // rather than trapping in the Int conversion.
        let huge = Fraction(1e20)
        XCTAssertEqual(huge.numerator, Int.max)
        XCTAssertEqual(huge.denominator, 1)
        XCTAssertEqual(huge.signum, 1)

        let negHuge = Fraction(-1e20)
        XCTAssertEqual(negHuge.numerator, -Int.max)
        XCTAssertEqual(negHuge.signum, -1)
    }

    /// The continued-fraction fallback returns a close, finite rational for
    /// irrational-looking doubles — exercised here mainly to prove it never
    /// traps and yields a sane value.
    func testInitApproximatesIrrationalDoubles() {
        let pi = Fraction(Double.pi)
        XCTAssertTrue(pi.isFinite)
        XCTAssertEqual(Double(pi.numerator) / Double(pi.denominator), Double.pi, accuracy: 1e-9)

        let third = Fraction(1.0 / 3.0)
        XCTAssertTrue(third.isFinite)
        XCTAssertEqual(Double(third.numerator) / Double(third.denominator), 1.0 / 3.0, accuracy: 1e-9)
    }

    /// The mixed arithmetic operators still route Double operands through
    /// Fraction(rhs); now that init is total this can no longer crash on
    /// scientific-notation values.
    func testMixedArithmeticWithScientificNotationDouble() {
        XCTAssertEqual(Fraction.one + 1e-13, Fraction.one)
        XCTAssertEqual(Fraction.one - 1e-13, Fraction.one)
        XCTAssertEqual(Fraction.one * 1e-13, Fraction.zero)
    }

    /// A float literal resolves through ExpressibleByFloatLiteral →
    /// init(floatLiteral:) → init(_ n: Double). This is the client-facing sugar
    /// that first surfaced the recursion, so it is worth pinning down.
    func testFloatLiteralConversion() {
        let f: Fraction = 0.5
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
    }

    /// Boundary magnitudes around Int.max, and the extremes of the finite Double
    /// range, must convert without trapping in the internal Int(_:) conversions.
    func testInitFromExtremeMagnitudeDoubles() {
        // At and beyond Int.max the result saturates to an Int-backed value.
        XCTAssertEqual(Fraction(Double(Int.max)).numerator, Int.max)
        XCTAssertEqual(Fraction(Double.greatestFiniteMagnitude).numerator, Int.max)
        XCTAssertEqual(Fraction(-Double.greatestFiniteMagnitude).numerator, -Int.max)

        // The smallest positive Double is well below the approximation epsilon.
        XCTAssertEqual(Fraction(Double.leastNonzeroMagnitude), Fraction.zero)

        // A near-integer whose continued-fraction reciprocal blows up must still
        // terminate with a sane finite value.
        let nearInt = Fraction(1.0 + 1e-11)
        XCTAssertTrue(nearInt.isFinite)
        XCTAssertEqual(Double(nearInt.numerator) / Double(nearInt.denominator), 1.0 + 1e-11, accuracy: 1e-9)
    }

    /// init?(exactly:) returns the exact fraction for representable decimals and
    /// nil (rather than an approximation or a trap) for values with no exact
    /// plain-decimal form.
    func testInitExactly() {
        XCTAssertEqual(Fraction(exactly: 0.5), Fraction(num: 1, den: 2))
        XCTAssertEqual(Fraction(exactly: -3.0), Fraction(num: -3, den: 1))
        XCTAssertNil(Fraction(exactly: 1e-13))
        XCTAssertNil(Fraction(exactly: Double.nan))
        XCTAssertNil(Fraction(exactly: Double.infinity))
    }
}
