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

    /// Creates a fraction from the plain decimal string form of `n`.
    ///
    /// IMPORTANT: this initializer (and `exactDecimal`) must never compare `n`
    /// against a numeric literal (e.g. `n < 0.0`). With the heterogeneous
    /// `< (Double, Fraction)` operators in scope, some Swift compiler versions
    /// resolve such comparisons to the Fraction overload, which converts the
    /// literal via this very initializer — infinite recursion and a
    /// stack-overflow crash in release builds.
    public init(_ n: Double) {
        guard let fraction = Self.exactDecimal(n) else {
            preconditionFailure("Fraction(Double) requires a plain finite decimal value, got \(n)")
        }
        self = fraction
    }

    public init(_ n: Float) {
        self.init(Double(n))
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
    /// exact fraction. Returns nil for values whose description is not plain
    /// decimal (scientific notation like "1e-13", "inf", "nan") or whose
    /// digits overflow Int. Unlike `init(_ n: Double)`, this never traps, so
    /// it is safe for the mixed-type `==` operators, which the compiler may
    /// substitute into plain Double comparisons in client code.
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
public extension Double {
    init (_ fraction: Fraction) {
        self = Double(fraction.numerator) / Double(fraction.denominator)
    }

    // Exact comparison via a non-trapping parse: Fraction(Double) is
    // string-based and traps on values that stringify in scientific notation
    // (e.g. 1e-13). These operators can be chosen by the compiler for plain
    // `someDouble == literal` comparisons in client code, so they must be
    // safe for any Double. Unrepresentable doubles are never exactly equal.
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

    // See the Double `==` operators above: exact comparison via the
    // non-trapping parser instead of the trapping Fraction(Double) init.
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
