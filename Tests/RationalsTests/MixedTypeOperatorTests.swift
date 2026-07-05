import XCTest
@testable import Rationals

/// Exercises the heterogeneous Fraction↔Int/Double/Float operators.
///
/// IMPORTANT: every mixed-type operand here is a typed *variable*, never a
/// literal. With a literal (`Fraction.NaN < 1`, `Fraction.one + 1e-13`) the
/// compiler prefers converting the literal to Fraction and calling the
/// homogeneous operator, so the heterogeneous overloads are silently skipped —
/// the same overload-resolution behavior behind the Fraction(Double) recursion
/// crash. Coverage data confirms literals leave these functions unexecuted.
final class MixedTypeOperatorTests: XCTestCase {

    // MARK: - Fraction ↔ Int

    func testIntEquality() {
        let three: Int = 3
        XCTAssertTrue(Fraction(num: 3, den: 1) == three)
        XCTAssertTrue(three == Fraction(num: 3, den: 1))
        XCTAssertFalse(Fraction(num: 1, den: 2) == three)
        XCTAssertFalse(three == Fraction(num: 1, den: 2))

        let zero: Int = 0
        XCTAssertTrue(Fraction.zero == zero)
        XCTAssertTrue(zero == Fraction.zero)
    }

    func testIntComparisons() {
        let two: Int = 2
        let half = Fraction(num: 1, den: 2)

        XCTAssertTrue(half < two)
        XCTAssertFalse(half > two)
        XCTAssertTrue(half <= two)
        XCTAssertFalse(half >= two)

        XCTAssertFalse(two < half)
        XCTAssertTrue(two > half)
        XCTAssertFalse(two <= half)
        XCTAssertTrue(two >= half)

        // Equal values through both <= and >=.
        let one: Int = 1
        XCTAssertTrue(Fraction.one <= one)
        XCTAssertTrue(Fraction.one >= one)
        XCTAssertTrue(one <= Fraction.one)
        XCTAssertTrue(one >= Fraction.one)
    }

    func testIntComparisonsWithNaNAreFalse() {
        let one: Int = 1
        XCTAssertFalse(Fraction.NaN < one)
        XCTAssertFalse(Fraction.NaN > one)
        XCTAssertFalse(Fraction.NaN <= one)
        XCTAssertFalse(Fraction.NaN >= one)
        XCTAssertFalse(one < Fraction.NaN)
        XCTAssertFalse(one > Fraction.NaN)
        XCTAssertFalse(one <= Fraction.NaN)
        XCTAssertFalse(one >= Fraction.NaN)
    }

    func testIntArithmetic() {
        let three: Int = 3
        let half = Fraction(num: 1, den: 2)

        XCTAssertEqual(half + three, Fraction(num: 7, den: 2))
        XCTAssertEqual(half - three, Fraction(num: -5, den: 2))
        XCTAssertEqual(half * three, Fraction(num: 3, den: 2))
        XCTAssertEqual(half / three, Fraction(num: 1, den: 6))
    }

    func testIntCompoundAssignment() {
        let two: Int = 2
        var f = Fraction(num: 1, den: 2)

        f += two
        XCTAssertEqual(f, Fraction(num: 5, den: 2))
        f -= two
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
        f *= two
        XCTAssertEqual(f, Fraction.one)
        f /= two
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
    }

    // MARK: - Fraction ↔ Double

    func testDoubleComparisons() {
        let halfD: Double = 0.5
        let quarter = Fraction(num: 1, den: 4)
        let half = Fraction(num: 1, den: 2)

        XCTAssertTrue(quarter < halfD)
        XCTAssertFalse(quarter > halfD)
        XCTAssertTrue(quarter <= halfD)
        XCTAssertFalse(quarter >= halfD)
        XCTAssertTrue(half <= halfD)
        XCTAssertTrue(half >= halfD)

        XCTAssertFalse(halfD < quarter)
        XCTAssertTrue(halfD > quarter)
        XCTAssertFalse(halfD <= quarter)
        XCTAssertTrue(halfD >= quarter)
        XCTAssertTrue(halfD <= half)
        XCTAssertTrue(halfD >= half)
    }

    func testDoubleComparisonsWithNaNAreFalse() {
        let oneD: Double = 1.0
        XCTAssertFalse(Fraction.NaN < oneD)
        XCTAssertFalse(Fraction.NaN > oneD)
        XCTAssertFalse(Fraction.NaN <= oneD)
        XCTAssertFalse(Fraction.NaN >= oneD)
        XCTAssertFalse(oneD < Fraction.NaN)
        XCTAssertFalse(oneD > Fraction.NaN)
        XCTAssertFalse(oneD <= Fraction.NaN)
        XCTAssertFalse(oneD >= Fraction.NaN)
    }

    func testDoubleArithmetic() {
        let quarterD: Double = 0.25
        let half = Fraction(num: 1, den: 2)

        XCTAssertEqual(half + quarterD, Fraction(num: 3, den: 4))
        XCTAssertEqual(half - quarterD, Fraction(num: 1, den: 4))
        XCTAssertEqual(half * quarterD, Fraction(num: 1, den: 8))
        XCTAssertEqual(half / quarterD, Fraction(num: 2, den: 1))

        // Scientific-notation doubles route through the total init and must
        // not trap (variable-typed counterpart of the literal regression test).
        let tiny: Double = 1e-13
        XCTAssertEqual(Fraction.one + tiny, Fraction.one)
        XCTAssertEqual(Fraction.one - tiny, Fraction.one)
        XCTAssertEqual(Fraction.one * tiny, Fraction.zero)
    }

    func testFractionCompoundAssignmentWithDouble() {
        let quarterD: Double = 0.25
        var f = Fraction(num: 1, den: 2)

        f += quarterD
        XCTAssertEqual(f, Fraction(num: 3, den: 4))
        f -= quarterD
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
        f *= quarterD
        XCTAssertEqual(f, Fraction(num: 1, den: 8))
        f /= quarterD
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
    }

    func testDoubleCompoundAssignmentWithFraction() {
        var d: Double = 1.0
        let half = Fraction(num: 1, den: 2)

        d += half
        XCTAssertEqual(d, 1.5)
        d -= half
        XCTAssertEqual(d, 1.0)
        d *= half
        XCTAssertEqual(d, 0.5)
        d /= half
        XCTAssertEqual(d, 1.0)
    }

    // MARK: - Fraction ↔ Float

    func testFloatInitAndConversion() {
        let halfF: Float = 0.5
        XCTAssertEqual(Fraction(halfF), Fraction(num: 1, den: 2))
        XCTAssertEqual(Float(Fraction(num: 1, den: 2)), halfF)
    }

    func testFloatEquality() {
        let halfF: Float = 0.5
        XCTAssertTrue(Fraction(num: 1, den: 2) == halfF)
        XCTAssertTrue(halfF == Fraction(num: 1, den: 2))

        // A float whose double value stringifies in scientific notation has no
        // exact decimal form: equality is false via the nil branch, not a trap.
        let tinyF: Float = 1e-13
        XCTAssertFalse(Fraction.zero == tinyF)
        XCTAssertFalse(tinyF == Fraction.zero)
    }

    func testFloatComparisons() {
        let halfF: Float = 0.5
        let quarter = Fraction(num: 1, den: 4)
        let half = Fraction(num: 1, den: 2)

        XCTAssertTrue(quarter < halfF)
        XCTAssertFalse(quarter > halfF)
        XCTAssertTrue(quarter <= halfF)
        XCTAssertFalse(quarter >= halfF)
        XCTAssertTrue(half <= halfF)
        XCTAssertTrue(half >= halfF)

        XCTAssertFalse(halfF < quarter)
        XCTAssertTrue(halfF > quarter)
        XCTAssertFalse(halfF <= quarter)
        XCTAssertTrue(halfF >= quarter)
    }

    func testFloatComparisonsWithNaNAreFalse() {
        let oneF: Float = 1.0
        XCTAssertFalse(Fraction.NaN < oneF)
        XCTAssertFalse(Fraction.NaN >= oneF)
        XCTAssertFalse(oneF < Fraction.NaN)
        XCTAssertFalse(oneF >= Fraction.NaN)
    }

    func testFloatArithmetic() {
        let quarterF: Float = 0.25
        let half = Fraction(num: 1, den: 2)

        XCTAssertEqual(half + quarterF, Fraction(num: 3, den: 4))
        XCTAssertEqual(half - quarterF, Fraction(num: 1, den: 4))
        XCTAssertEqual(half * quarterF, Fraction(num: 1, den: 8))
        XCTAssertEqual(half / quarterF, Fraction(num: 2, den: 1))
    }

    func testFractionCompoundAssignmentWithFloat() {
        let quarterF: Float = 0.25
        var f = Fraction(num: 1, den: 2)

        f += quarterF
        XCTAssertEqual(f, Fraction(num: 3, den: 4))
        f -= quarterF
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
        f *= quarterF
        XCTAssertEqual(f, Fraction(num: 1, den: 8))
        f /= quarterF
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
    }

    // MARK: - Fraction ↔ Fraction compound assignment

    func testFractionCompoundAssignment() {
        var f = Fraction(num: 1, den: 2)

        f += Fraction(num: 1, den: 3)
        XCTAssertEqual(f, Fraction(num: 5, den: 6))
        f -= Fraction(num: 1, den: 3)
        XCTAssertEqual(f, Fraction(num: 1, den: 2))
        f *= Fraction(num: 2, den: 1)
        XCTAssertEqual(f, Fraction.one)
        f /= Fraction(num: 4, den: 1)
        XCTAssertEqual(f, Fraction(num: 1, den: 4))
    }

    // MARK: - init?(exactly: BinaryInteger)

    func testInitExactlyBinaryInteger() {
        XCTAssertEqual(Fraction(exactly: 5 as Int8), Fraction(num: 5, den: 1))
        XCTAssertEqual(Fraction(exactly: -5 as Int8), Fraction(num: -5, den: 1))
        XCTAssertEqual(Fraction(exactly: 42 as UInt), Fraction(num: 42, den: 1))
        XCTAssertEqual(Fraction(exactly: UInt64(Int.max)), Fraction(num: Int.max, den: 1))

        // Values that do not fit in Int return nil rather than trapping.
        XCTAssertNil(Fraction(exactly: UInt64.max))
        XCTAssertNil(Fraction(exactly: UInt64(Int.max) + 1))
    }
}
