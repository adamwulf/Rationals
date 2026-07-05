import XCTest
@testable import Rationals

/// A deterministic RNG (SplitMix64) so randomized tests are reproducible.
private struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

final class FractionCorrectnessTests: XCTestCase {

    // MARK: - Exact comparison

    /// `<` must compare exactly, not through Double: these two fractions
    /// round to the same Double but are distinct rationals.
    func testComparisonIsExactBeyondDoublePrecision() {
        let justOverOne = Fraction(num: 9007199254740993, den: 9007199254740992)  // (2^53+1)/2^53
        XCTAssertTrue(Fraction.one < justOverOne)
        XCTAssertFalse(justOverOne < Fraction.one)
        XCTAssertTrue(justOverOne > Fraction.one)
        XCTAssertNotEqual(justOverOne, Fraction.one)
    }

    /// The Fraction↔Int comparisons delegate to the exact Fraction comparison.
    func testIntComparisonIsExact() {
        let justOverBig = Fraction(num: 9007199254740993, den: 1)  // 2^53 + 1
        XCTAssertTrue(justOverBig > 9007199254740992)
        XCTAssertTrue(9007199254740992 < justOverBig)
        XCTAssertFalse(justOverBig <= 9007199254740992)
    }

    func testBasicComparisons() {
        XCTAssertTrue(Fraction(num: 1, den: 3) < Fraction(num: 1, den: 2))
        XCTAssertTrue(Fraction(num: -1, den: 2) < Fraction(num: -1, den: 3))
        XCTAssertTrue(Fraction(num: -1, den: 2) < Fraction.zero)
        XCTAssertTrue(Fraction(num: 2, den: 4) <= Fraction(num: 1, den: 2))
        XCTAssertTrue(Fraction(num: 2, den: 4) >= Fraction(num: 1, den: 2))

        XCTAssertTrue(Fraction(num: 1, den: 2) < 1)
        XCTAssertTrue(0 < Fraction(num: 1, den: 2))
        XCTAssertTrue(Fraction(num: 3, den: 1) == 3)
        XCTAssertTrue(3 == Fraction(num: 3, den: 1))
        XCTAssertTrue(Fraction(num: 3, den: 1) >= 3)
        XCTAssertTrue(Fraction(num: 3, den: 1) <= 3)
    }

    // MARK: - Non-finite ordering

    func testInfinityOrdering() {
        XCTAssertTrue(-Fraction.infinity < Fraction.zero)
        XCTAssertTrue(-Fraction.infinity < Fraction.infinity)
        XCTAssertTrue(Fraction.zero < Fraction.infinity)
        XCTAssertTrue(Fraction(num: Int.max, den: 1) < Fraction.infinity)
        XCTAssertFalse(Fraction.infinity < Fraction.infinity)
        XCTAssertFalse(-Fraction.infinity < -Fraction.infinity)
    }

    /// NaN is unordered: <, >, <=, >= involving NaN are all false. (Equality
    /// is structural, so NaN == NaN is deliberately true — see `==` docs.)
    func testNaNComparisonsAreFalse() {
        XCTAssertFalse(Fraction.NaN < Fraction.one)
        XCTAssertFalse(Fraction.one < Fraction.NaN)
        XCTAssertFalse(Fraction.NaN > Fraction.one)
        XCTAssertFalse(Fraction.NaN >= Fraction.one)
        XCTAssertFalse(Fraction.NaN <= Fraction.one)

        XCTAssertFalse(Fraction.NaN < 1)
        XCTAssertFalse(Fraction.NaN >= 1)
        XCTAssertFalse(1 < Fraction.NaN)

        XCTAssertFalse(Fraction.NaN < 1.0)
        XCTAssertFalse(Fraction.NaN >= 1.0)
        XCTAssertFalse(1.0 <= Fraction.NaN)
        XCTAssertFalse(Fraction.one < Double.nan)
        XCTAssertFalse(Fraction.one >= Double.nan)

        XCTAssertEqual(Fraction.NaN, Fraction.NaN)
    }

    // MARK: - Exact arithmetic

    /// Integer-built fractions stay on the exact path: no Double is involved,
    /// and results are exact, reduced rationals.
    func testExactArithmetic() {
        XCTAssertEqual(Fraction(num: 1, den: 3) * Fraction(num: 1, den: 3), Fraction(num: 1, den: 9))
        XCTAssertEqual(Fraction(num: 2, den: 3) * Fraction(num: 3, den: 4), Fraction(num: 1, den: 2))
        XCTAssertEqual(Fraction(num: -1, den: 3) * Fraction(num: 1, den: 3), Fraction(num: -1, den: 9))

        XCTAssertEqual(Fraction(num: 1, den: 3) + Fraction(num: 1, den: 6), Fraction(num: 1, den: 2))
        XCTAssertEqual(Fraction(num: 1, den: 3) - Fraction(num: 1, den: 2), Fraction(num: -1, den: 6))

        XCTAssertEqual(Fraction(num: 1, den: 3) / Fraction(num: 1, den: 9), Fraction(num: 3, den: 1))
        XCTAssertEqual(Fraction(num: 5, den: 7) / Fraction(num: 5, den: 7), Fraction.one)
    }

    // MARK: - Non-finite arithmetic

    func testInfinityArithmetic() {
        XCTAssertEqual(Fraction.infinity + Fraction.infinity, Fraction.infinity)
        XCTAssertEqual(-Fraction.infinity - Fraction.infinity, -Fraction.infinity)
        XCTAssertTrue((Fraction.infinity - Fraction.infinity).isNaN)
        XCTAssertEqual(Fraction.infinity + Fraction.one, Fraction.infinity)
        XCTAssertEqual(Fraction.one - Fraction.infinity, -Fraction.infinity)

        XCTAssertTrue((Fraction.infinity * Fraction.zero).isNaN)
        XCTAssertEqual(Fraction.infinity * Fraction(num: -2, den: 1), -Fraction.infinity)
        XCTAssertEqual(Fraction.infinity * Fraction.infinity, Fraction.infinity)

        XCTAssertTrue((Fraction.NaN + Fraction.one).isNaN)
        XCTAssertTrue((Fraction.one * Fraction.NaN).isNaN)

        // Division by zero yields a signed infinity; 0/0 is NaN.
        XCTAssertEqual(Fraction.one / Fraction.zero, Fraction.infinity)
        XCTAssertEqual(Fraction(num: -1, den: 1) / Fraction.zero, -Fraction.infinity)
        XCTAssertTrue((Fraction.zero / Fraction.zero).isNaN)
    }

    // MARK: - Reciprocal, magnitude, description

    func testReciprocal() {
        XCTAssertEqual(Fraction(num: 2, den: 3).reciprocal, Fraction(num: 3, den: 2))
        XCTAssertEqual(Fraction(num: -1, den: 2).reciprocal, Fraction(num: -2, den: 1))
        XCTAssertEqual(Fraction.zero.reciprocal, Fraction.infinity)
        XCTAssertEqual(Fraction.infinity.reciprocal, Fraction.zero)
        XCTAssertTrue(Fraction.NaN.reciprocal.isNaN)
    }

    func testMagnitude() {
        XCTAssertEqual(Fraction(num: -2, den: 3).magnitude, Fraction(num: 2, den: 3))
        XCTAssertEqual(Fraction(num: 2, den: 3).magnitude, Fraction(num: 2, den: 3))
        XCTAssertEqual(Fraction.zero.magnitude, Fraction.zero)
        XCTAssertEqual((-Fraction.infinity).magnitude, Fraction.infinity)
    }

    func testDescription() {
        XCTAssertEqual(Fraction(num: -7, den: 3).description, "-7/3")
        XCTAssertEqual(Fraction(num: 6, den: 2).description, "3")
        XCTAssertEqual(Fraction.zero.description, "0")
        XCTAssertEqual(Fraction.infinity.description, "inf")
        XCTAssertEqual((-Fraction.infinity).description, "-inf")
        XCTAssertEqual(Fraction.NaN.description, "nan")
    }

    // MARK: - Conversions

    func testIntFromFractionTruncates() {
        XCTAssertEqual(Int(Fraction(num: 7, den: 2)), 3)
        XCTAssertEqual(Int(Fraction(num: -7, den: 2)), -3)
        XCTAssertEqual(Int(Fraction(num: 4, den: 2)), 2)
        XCTAssertEqual(Int(Fraction.zero), 0)
    }

    // MARK: - Hashable & Codable

    func testHashableUsesReducedForm() {
        let set: Set<Fraction> = [Fraction(num: 1, den: 2), Fraction(num: 2, den: 4), Fraction(num: 1, den: 3)]
        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(Fraction(num: 3, den: 6)))
    }

    func testCodableRoundTrip() throws {
        let values: [Fraction] = [Fraction(num: -7, den: 3),
                                  Fraction.zero,
                                  Fraction.one,
                                  Fraction.infinity,
                                  -Fraction.infinity,
                                  Fraction.NaN]
        let data = try JSONEncoder().encode(values)
        let decoded = try JSONDecoder().decode([Fraction].self, from: data)
        XCTAssertEqual(decoded, values)
        XCTAssertEqual(decoded.map({ $0.signum }), values.map({ $0.signum }))
    }

    func testDecodingNormalizesPayload() throws {
        // A payload that is neither reduced nor sign-normalized must decode
        // through init(num:den:) into canonical form.
        let json = Data(#"{"numerator":2,"denominator":-4}"#.utf8)
        let decoded = try JSONDecoder().decode(Fraction.self, from: json)
        XCTAssertEqual(decoded.numerator, -1)
        XCTAssertEqual(decoded.denominator, 2)
        XCTAssertEqual(decoded.signum, -1)
    }

    // MARK: - Strideable

    func testStriding() {
        let quarters = Array(stride(from: Fraction.zero, to: Fraction.one, by: Fraction(num: 1, den: 4)))
        XCTAssertEqual(quarters, [Fraction.zero,
                                  Fraction(num: 1, den: 4),
                                  Fraction(num: 1, den: 2),
                                  Fraction(num: 3, den: 4)])
    }

    // MARK: - Randomized round trip

    /// Double → Fraction → Double stays within a tight relative error for a
    /// deterministic spread of magnitudes.
    func testDoubleRoundTripAccuracy() {
        var rng = SplitMix64(state: 0x524154494F4E414C)  // "RATIONAL"
        for magnitude in [1.0, 1e3, 1e6] {
            for _ in 0..<300 {
                let x = Double.random(in: -magnitude...magnitude, using: &rng)
                let f = Fraction(x)
                XCTAssertTrue(f.isFinite, "Fraction(\(x)) must be finite")
                let tolerance = Swift.max(abs(x) * 1e-9, 1e-9)
                XCTAssertEqual(Double(f), x, accuracy: tolerance, "round trip drifted for \(x)")
            }
        }
    }

    /// Fraction → Double → Fraction is exact for fractions that Double can
    /// represent exactly (power-of-two denominators).
    func testExactRoundTripForDyadicFractions() {
        var rng = SplitMix64(state: 42)
        for _ in 0..<300 {
            let den = 1 << Int.random(in: 0...20, using: &rng)
            let num = Int.random(in: -1000...1000, using: &rng)
            let f = Fraction(num: num, den: den)
            XCTAssertEqual(Fraction(Double(f)), f)
        }
    }
}
