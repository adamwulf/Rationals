//
//  Fraction.swift
//  Fraction
//
//  Created by Noah Wilder on 2018-11-27.
//  Copyright © 2018 Noah Wilder. All rights reserved.
//

import Foundation

/// A fraction consisting of a `numerator` and a `denominator`
public struct Fraction {
    // MARK: - Properties

    public private(set) var numerator: Int
    public private(set) var denominator: Int
    public private(set) var signum: Int = 1

    // MARK: - Constants

    public static let max = Int.max
    public static let min = Int.min
    public static let zero = Fraction(num: 0, den: 1)
    public static let one = Fraction(num: 1, den: 1)
    public static let infinity = Fraction(num: 1, den: 0)
    public static let NaN = Fraction(num: 0, den: 0)

    // MARK: - Initializers

    public init(num: Int, den: Int) {
        var result = Self.reduce(numerator: num, denominator: den)

        // set the sign, also ensure that if negative, the numerator is negative and denominator is positive.
        // if the fraction is zero, then sign is zero.
        if result.numerator == 0 {
            signum = 0
        } else {
            switch result.denominator.signum() + result.numerator.signum() {
            case -2:
                result.denominator = abs(result.denominator)
                result.numerator = abs(result.numerator)
                signum = 1
            case -1:
                signum = -1
            case 0:
                signum = -1
                if result.numerator.signum() == 1 {
                    result.numerator   *= -1
                    result.denominator *= -1
                }
            case 1:
                signum = 1
            case 2:
                signum = 1
            default: break
            }
        }

        numerator = result.numerator
        denominator = result.denominator
    }

    public init(_ n: Int) {
        self.init(num: n, den: 1)
    }

    /// Creates a fraction from `n`. This initializer is **total**: every
    /// `Double` maps to a `Fraction` and it never traps.
    ///
    /// - `NaN` maps to `Fraction.NaN`, `±infinity` to `±Fraction.infinity`.
    /// - Values whose textual form is plain decimal (e.g. `"123.456"`) are
    ///   converted exactly via `exactDecimal`.
    /// - Any other finite value (scientific-notation magnitudes like `1e-13`
    ///   or `1e20`, or one whose exact digits overflow `Int`) is converted to
    ///   the closest rational with a bounded denominator via `approximate`.
    ///
    /// IMPORTANT: this initializer (and every helper it calls) must never
    /// compare `n` against a numeric literal (e.g. `n < 0.0`). With the
    /// heterogeneous `< (Double, Fraction)` operators in scope, some Swift
    /// compiler versions resolve such comparisons to the `Fraction` overload,
    /// which converts the literal via this very initializer — infinite
    /// recursion and a stack-overflow crash in release builds. Derive signs
    /// from `n.sign` and only ever compare `Double` *variables* to each other.
    public init(_ n: Double) {
        guard !n.isNaN else { self = Fraction.NaN; return }
        let sign = n.sign == .minus ? -1 : 1
        guard !n.isInfinite else { self = Fraction(num: sign, den: 0); return }
        if let fraction = Self.exactDecimal(n) {
            self = fraction
            return
        }
        self = Self.approximate(n)
    }

    public init(_ n: Float) {
        self.init(Double(n))
    }

    /// Creates a fraction that is *exactly* equal to `n`, or returns `nil` when
    /// `n` has no exact plain-decimal representation (scientific-notation
    /// magnitudes like `1e-13`, non-finite values, or exact digits that
    /// overflow `Int`).
    ///
    /// This mirrors the standard library's `Int(exactly:)` convention: it is
    /// the honest API for callers that require exactness and want to handle the
    /// inexact case themselves, as opposed to the total, possibly-lossy
    /// `init(_ n: Double)`.
    public init?(exactly n: Double) {
        guard let fraction = Self.exactDecimal(n) else { return nil }
        self = fraction
    }
}

extension Fraction {
    static func gcd(_ lhs: Int, _ rhs: Int) -> Int {
        var lhs = lhs
        var rhs = rhs
        while rhs != 0 { (lhs, rhs) = (rhs, lhs % rhs) }
        return lhs
    }

    static func lcm(_ lhs: Int, _ rhs: Int) -> Int {
        return lhs / gcd(lhs, rhs) * rhs
    }

    static func reduce(numerator: Int, denominator: Int) -> (numerator: Int, denominator: Int) {
        var divisor = gcd(numerator, denominator)
        if divisor < 0 { divisor *= -1 }
        guard divisor != 0 else { return (numerator: numerator, denominator: 0) }
        return (numerator: numerator / divisor, denominator: denominator / divisor)
    }

    static func commonDenominator(_ lhs: Fraction, _ rhs: Fraction) -> (lhsNumerator: Int, rhsNumberator: Int, denominator: Int) {
        let denominator = lcm(lhs.denominator, rhs.denominator)
        let lhsNumerator = lhs.numerator * (denominator / lhs.denominator)
        let rhsNumerator = rhs.numerator * (denominator / rhs.denominator)

        return (lhsNumerator, rhsNumerator, denominator)
    }

    /// Parses the plain decimal string form of `n` (e.g. "123.456") into an
    /// *exact* fraction. Returns nil for values whose description is not plain
    /// decimal (scientific notation like "1e-13", "inf", "nan") or whose digits
    /// overflow Int. This is the exact, non-approximating path shared by the
    /// public `init?(exactly:)`, the fast path of the total `init(_:)`, and the
    /// mixed-type `==` operators (where an unrepresentable value means "not
    /// equal", never an approximate comparison). It never traps.
    static func exactDecimal(_ n: Double) -> Fraction? {
        let nArr = "\(n)".split(separator: ".")
        guard nArr.count == 2,
              let pre = Int(nArr[0]),
              let post = Int(nArr[1]) else { return nil }
        guard post != 0 else { return Fraction(num: pre, den: 1) }
        let sign = n.sign == .minus ? -1 : 1
        let den = Int(pow(10.0, Double(nArr[1].count)))
        return Fraction(num: sign * (post + abs(pre) * den), den: den)
    }

    /// The largest denominator `approximate` will use when converting a Double
    /// that has no exact plain-decimal form. Convergents beyond this are
    /// discarded in favour of the best approximation found so far.
    static let maxApproximationDenominator = 1_000_000_000

    /// Returns the closest `Fraction` to a finite `n` using the continued
    /// fraction algorithm, bounding the denominator by
    /// `maxApproximationDenominator`. Always returns a value — this is the
    /// fallback path of the total `init(_ n: Double)` for finite values that
    /// `exactDecimal` cannot represent (scientific-notation magnitudes, or
    /// values whose exact decimal digits overflow `Int`).
    ///
    /// Callers must pass a finite `n`; `NaN`/`infinity` are handled earlier in
    /// `init(_ n: Double)`. Per the golden rule, sign is taken from `n.sign`
    /// and every `Double` comparison here is between two *variables* (never a
    /// literal), so no comparison can be rerouted to a heterogeneous
    /// `Fraction` operator and back into this conversion path.
    static func approximate(_ n: Double) -> Fraction {
        let sign = n.sign == .minus ? -1 : 1
        let absValue = abs(n)

        // Zero (including -0.0) — compare against a Double *variable*, not a literal.
        let zero = 0.0
        guard absValue > zero else { return Fraction.zero }

        // Magnitudes at or beyond Int.max cannot seed the continued fraction
        // without trapping in `Int(floor(x))`; saturate to the closest value an
        // Int-backed fraction can hold. (`Double(Int.max)` rounds *up* to 2^63,
        // so `>=` here rejects exactly the values `Int(_:)` would reject.)
        let maxIntAsDouble = Double(Int.max)
        guard absValue < maxIntAsDouble else {
            return Fraction(num: sign * Int.max, den: 1)
        }

        // Whole numbers convert directly.
        if absValue == floor(absValue) {
            return Fraction(num: sign * Int(absValue), den: 1)
        }

        // Standard continued-fraction recurrence:
        //   h_n = a_n * h_{n-1} + h_{n-2},  k_n = a_n * k_{n-1} + k_{n-2}
        // seeded with h_{-1}=1, k_{-1}=0, h_0=a_0, k_0=1.
        var x = absValue
        var p0 = 1, q0 = 0            // h_{-1}, k_{-1}
        let a0 = Int(floor(x))       // safe: x < Double(Int.max) guaranteed above
        var p1 = a0, q1 = 1          // h_0, k_0
        x = x - Double(a0)

        var bestP = p1
        var bestQ = q1

        let epsilon = 1e-12
        while x > epsilon {
            x = 1.0 / x
            // The next partial quotient can exceed Int range if x is enormous
            // (a near-integer input drives the reciprocal huge); stop with the
            // best convergent so far rather than trap in Int(floor(x)).
            guard x < maxIntAsDouble else { break }
            let a = Int(floor(x))
            x = x - Double(a)

            // Guard every step of the recurrence against Int overflow. On
            // overflow we keep the best convergent found so far rather than
            // trap — init(_ n: Double) must stay total.
            let (ap1, o1) = a.multipliedReportingOverflow(by: p1)
            guard !o1 else { break }
            let (p2, o2) = ap1.addingReportingOverflow(p0)
            guard !o2 else { break }
            let (aq1, o3) = a.multipliedReportingOverflow(by: q1)
            guard !o3 else { break }
            let (q2, o4) = aq1.addingReportingOverflow(q0)
            guard !o4 else { break }

            guard q2 <= maxApproximationDenominator else { break }

            p0 = p1
            q0 = q1
            p1 = p2
            q1 = q2
            bestP = p1
            bestQ = q1
        }

        return Fraction(num: sign * bestP, den: bestQ)
    }
}

// MARK: - Computed Properties
public extension Fraction {
    /// The reciprocal of the fraction.
    var reciprocal: Fraction {
        get {
            return Fraction(num: denominator, den: numerator)
        }
    }

    var isWholeNumber: Bool {
        return !isNaN && (denominator == 1 || numerator == 0)
    }

    /// `true` iff `self` is neither infinite nor NaN
    var isFinite: Bool {
        return denominator != 0
    }

    /// `true` iff the numerator is zero and the denominator is nonzero
    var isInfinite: Bool {
        return denominator == 0 && numerator != 0
    }

    /// `true` iff both the numerator and the denominator are zero
    var isNaN: Bool {
        return denominator == 0 && numerator == 0
    }
}

// MARK: - CustomStringConvertible
extension Fraction: CustomStringConvertible {
    public var description: String {

        guard denominator != 1 && numerator != 0 else { return "\(numerator)" }

        return "\(numerator)/\(denominator)"
    }
}

// MARK: - Equatable
extension Fraction: Equatable {
    public static func == (lhs: Fraction, rhs: Fraction) -> Bool {
        return lhs.numerator == rhs.numerator && lhs.denominator == rhs.denominator
    }
}

// MARK: - Comparable
extension Fraction: Comparable {
    public static func < (lhs: Fraction, rhs: Fraction) -> Bool {
        return Double(lhs.numerator) / Double(lhs.denominator) < Double(rhs.numerator) / Double(rhs.denominator)
    }
}

// MARK: - ExpressibleByIntegerLiteral
extension Fraction: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.init(num: value, den: 1)
    }
}

// MARK: - ExpressibleByFloatLiteral
extension Fraction: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double

    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

// MARK: - Strideable
extension Fraction: Strideable {
    public typealias Stride = Fraction

    public func distance(to other: Fraction) -> Fraction {
        return other.advanced(by: -self)
    }

    public func advanced(by n: Fraction) -> Fraction {
        guard isFinite || n.isFinite else { return Fraction.NaN }
        guard n.isFinite else { return n }
        guard isFinite else { return self }
        let (selfNumerator, nNumerator, commonDenominator) = Fraction.commonDenominator(self, n)
        return Fraction(num: selfNumerator + nNumerator, den: commonDenominator)
    }
}

// MARK: - Numeric
extension Fraction: Numeric {
    public var magnitude: Fraction {
        return self * self.signum
    }

    public typealias Magnitude = Fraction

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard let n = Int(exactly: source) else { return nil }

        self.init(num: n, den: 1)
    }

    // Binary arithmetic operators
    public static func + (lhs: Fraction, rhs: Fraction) -> Fraction {
        return lhs.advanced(by: rhs)
    }

    public static func - (lhs: Fraction, rhs: Fraction) -> Fraction {
        return lhs.advanced(by: -rhs)
    }

    public static func * (lhs: Fraction, rhs: Fraction) -> Fraction {
        return Fraction(num: lhs.numerator * rhs.numerator,
                        den: lhs.denominator * rhs.denominator)
    }

    public static func / (lhs: Fraction, rhs: Fraction) -> Fraction {
        return lhs * rhs.reciprocal
    }

    // Compound assignment operators
    public static func += (lhs: inout Fraction, rhs: Fraction) {
        lhs = lhs + rhs
    }
    public static func -= (lhs: inout Fraction, rhs: Fraction) {
        lhs = lhs - rhs
    }
    public static func *= (lhs: inout Fraction, rhs: Fraction) {
        lhs = lhs * rhs
    }
    public static func /= (lhs: inout Fraction, rhs: Fraction) {
        lhs = lhs / rhs
    }
}

// MARK: - SignedNumeric
extension Fraction: SignedNumeric {
    public mutating func negate() {
        numerator = -numerator
        signum = -signum
    }
}

// MARK: - Int Operators
public extension Int {
    init (_ fraction: Fraction) {
        self = fraction.numerator / fraction.denominator
    }

    static func == (lhs: Fraction, rhs: Int) -> Bool {
        return (lhs.numerator == 0 && rhs == 0) || (lhs.denominator == 1 && lhs.numerator == rhs)
    }
    static func == (lhs: Int, rhs: Fraction) -> Bool {
        return (rhs.numerator == 0 && lhs == 0) || (rhs.denominator == 1 && rhs.numerator == lhs)
    }

    static func < (lhs: Fraction, rhs: Int) -> Bool {
        return Double(lhs) < Double(rhs)
    }
    static func > (lhs: Fraction, rhs: Int) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Fraction, rhs: Int) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Fraction, rhs: Int) -> Bool {
        return !(lhs < rhs)
    }

    static func < (lhs: Int, rhs: Fraction) -> Bool {
        return Double(lhs) < Double(rhs)
    }
    static func > (lhs: Int, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Int, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Int, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    static func + (lhs: Fraction, rhs: Int) -> Fraction {
        return Fraction(num: lhs.numerator + (rhs * lhs.denominator),
                        den: lhs.denominator)
    }
    static func - (lhs: Fraction, rhs: Int) -> Fraction {
        return Fraction(num: lhs.numerator - rhs * lhs.denominator,
                        den: lhs.denominator)
    }
    static func * (lhs: Fraction, rhs: Int) -> Fraction {
        return Fraction(num: lhs.numerator * rhs,
                        den: lhs.denominator)
    }
    static func / (lhs: Fraction, rhs: Int) -> Fraction {
        return Fraction(num: lhs.numerator,
                        den: lhs.denominator * rhs)
    }

    static func += (lhs: inout Fraction, rhs: Int) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs / rhs
    }
}

// MARK: - Double Operators

// NOTE: These heterogeneous Fraction↔Double operators are the ones some Swift
// compilers pick for plain `someDouble <op> literal` comparisons in client
// code (the literal converts to Fraction implicitly). Now that every Double
// conversion path is total, that reroute is merely surprising, not fatal, so
// the operators are kept for source compatibility. Deleting them (forcing
// explicit conversions) would make the reroute impossible but is an API break
// with unknown downstream impact — a candidate for a future hardening pass, not
// this fix.
public extension Double {
    init (_ fraction: Fraction) {
        self = Double(fraction.numerator) / Double(fraction.denominator)
    }

    // Equality uses the exact, non-approximating parse (`exactDecimal`): a
    // Double with no exact plain-decimal form is never *exactly* equal to a
    // Fraction, so unrepresentable values return false rather than comparing an
    // approximation. (This is deliberately stricter than routing through the
    // total, lossy `init(_:)`.)
    static func == (lhs: Fraction, rhs: Double) -> Bool {
        guard let rhsFraction = Fraction.exactDecimal(rhs) else { return false }
        return lhs == rhsFraction
    }
    static func == (lhs: Double, rhs: Fraction) -> Bool {
        guard let lhsFraction = Fraction.exactDecimal(lhs) else { return false }
        return lhsFraction == rhs
    }

    static func < (lhs: Fraction, rhs: Double) -> Bool {
        return Double(lhs) < rhs
    }
    static func > (lhs: Fraction, rhs: Double) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Fraction, rhs: Double) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Fraction, rhs: Double) -> Bool {
        return !(lhs < rhs)
    }

    static func < (lhs: Double, rhs: Fraction) -> Bool {
        return lhs < Double(rhs)
    }
    static func > (lhs: Double, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Double, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Double, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    static func += (lhs: inout Double, rhs: Fraction) {
        lhs = lhs + Double(rhs)
    }
    static func -= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs - Double(rhs)
    }
    static func *= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs * Double(rhs)
    }
    static func /= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs / Double(rhs)
    }

    static func + (lhs: Fraction, rhs: Double) -> Fraction {
        return lhs + Fraction(rhs)
    }
    static func - (lhs: Fraction, rhs: Double) -> Fraction {
        return lhs - Fraction(rhs)
    }
    static func * (lhs: Fraction, rhs: Double) -> Fraction {
        return lhs * Fraction(rhs)
    }
    static func / (lhs: Fraction, rhs: Double) -> Fraction {
        return lhs / Fraction(rhs)
    }

    static func += (lhs: inout Fraction, rhs: Double) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs / rhs
    }
}

// MARK: - Float Operators
public extension Float {
    init (_ fraction: Fraction) {
        self = Float(fraction.numerator) / Float(fraction.denominator)
    }

    // See the Double `==` operators above: exact comparison via `exactDecimal`
    // rather than the total, lossy `Fraction(_:)` init.
    static func == (lhs: Fraction, rhs: Float) -> Bool {
        guard let rhsFraction = Fraction.exactDecimal(Double(rhs)) else { return false }
        return lhs == rhsFraction
    }
    static func == (lhs: Float, rhs: Fraction) -> Bool {
        guard let lhsFraction = Fraction.exactDecimal(Double(lhs)) else { return false }
        return lhsFraction == rhs
    }

    static func < (lhs: Fraction, rhs: Float) -> Bool {
        return Float(lhs) < rhs
    }
    static func > (lhs: Fraction, rhs: Float) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Fraction, rhs: Float) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Fraction, rhs: Float) -> Bool {
        return !(lhs < rhs)
    }

    static func < (lhs: Float, rhs: Fraction) -> Bool {
        return lhs < Float(rhs)
    }
    static func > (lhs: Float, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    static func <= (lhs: Float, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    static func >= (lhs: Float, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    static func + (lhs: Fraction, rhs: Float) -> Fraction {
        return lhs + Fraction(rhs)

    }
    static func - (lhs: Fraction, rhs: Float) -> Fraction {
        return lhs - Fraction(rhs)
    }
    static func * (lhs: Fraction, rhs: Float) -> Fraction {
        return lhs * Fraction(rhs)
    }
    static func / (lhs: Fraction, rhs: Float) -> Fraction {
        return lhs / Fraction(rhs)
    }

    static func += (lhs: inout Fraction, rhs: Float) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs / rhs
    }
}
