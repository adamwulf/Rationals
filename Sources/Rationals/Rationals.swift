//
//  Fraction.swift
//  Fraction
//
//  Created by Noah Wilder on 2018-11-27.
//  Copyright © 2018 Noah Wilder. All rights reserved.
//

import Foundation

// Precedence of exponent operator
precedencegroup ExponentPrecedence {

    associativity: left
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
    assignment: false

}

// Declaration of exponent operators
infix operator **: ExponentPrecedence
infix operator **=: AssignmentPrecedence

/// A fraction consisting of a `numerator` and a `denominator`
public struct Fraction {

    // Private stored properties
    private var _numerator: Int
    private var _denominator: Int

    // Stored property accessors
    public var numerator: Int {
        get {
            return _numerator
        }
        set {
            _numerator = newValue
            _adjustFraction()
        }

    }
    public var denominator: Int {
        get {
            return _denominator
        }
        set {
            precondition(_denominator != 0, "Cannot divide by 0")
            _denominator = newValue
            _adjustFraction()
        }
    }

    public private(set) var signum: Int = 1

    // Initializers
    public init(num: Int, den: Int) {

        precondition(den != 0, "Cannot divide by 0")

        self._numerator = num
        self._denominator = den

        _adjustFraction()
    }
    public init(_ numerator: Int, _ denominator: Int) {
        self.init(num: numerator, den: denominator)
    }
    public init(_ n: Int) {
        self.init(num: n, den: 1)
    }
    public init(_ n: Double) {
        let nArr = "\(n)".split(separator: ".")
        let decimal = (pre: Int(nArr[0])!, post: Int(nArr[1])!)

        let sign = n < 0.0 ? -1 : 1

        guard decimal.post != 0 else {
            self.init(num: sign * decimal.pre, den: 1)
            return
        }

        let den = Int(pow(10.0, Double(nArr[1].count)))
        self.init(num: sign * (decimal.post + abs(decimal.pre) * den), den: den)

    }
    public init(_ n: Float) {
        self.init(Double(n))
    }

    // Constants
    public static let max = Int.max
    public static let min = Int.min
    public static let zero = Fraction(num: 0, den: 1)

    // Computed properties
    public var decimal: Double {
        return Double(_numerator) / Double(_denominator)
    }
    public var isWholeNumber: Bool {
        return _denominator == 1 || _numerator == 0
    }

    // Binary arithmetic operators

    // Private functions
    private mutating func _adjustFraction() {
        self._setSignum()
        self._simplifyFraction()
    }
    private mutating func _simplifyFraction() {

        guard self._numerator != 0 && abs(self._numerator) != 1 && self._denominator != 1 else { return }

        for n in (2...Swift.min(abs(self._numerator), abs(self._denominator))).reversed() {
            if self._numerator % n == 0 && self._denominator % n == 0 {
                self._numerator /= n
                self._denominator /= n
                return
            }
        }

    }
    private mutating func _setSignum() {

        guard _numerator != 0 else {
            signum = 0
            return
        }

        switch _denominator.signum() + _numerator.signum() {
        case -2:
            _denominator = abs(_denominator)
            _numerator = abs(_numerator)
            signum = 1
        case 0:
            signum = -1
            if _numerator.signum() == 1 {
                _numerator   *= -1
                _denominator *= -1
            }

        case 2:
            signum = 1

        default: break

        }

    }

}

// Protocol Conformances
extension Fraction: CustomStringConvertible {
    public var description: String {

        guard _denominator != 1 && _numerator != 0 else { return "\(_numerator)" }

        return "\(_numerator)/\(_denominator)"
    }
}
extension Fraction: Equatable {
    public static func == (lhs: Fraction, rhs: Fraction) -> Bool {
        return lhs._numerator == rhs._numerator && lhs._denominator == rhs._denominator
    }
}
extension Fraction: Comparable {
    public static func < (lhs: Fraction, rhs: Fraction) -> Bool {
        return Double(lhs._numerator) / Double(lhs._denominator) < Double(rhs._numerator) / Double(rhs._denominator)
    }
}
extension Fraction: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.init(num: value, den: 1)
    }

}
extension Fraction: ExpressibleByFloatLiteral {

    public typealias FloatLiteralType = Double

    public init(floatLiteral value: Double) {
        self.init(value)
    }

}
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

        return Fraction(num: (lhs._numerator * rhs._denominator) + (rhs._numerator * lhs._denominator),
                        den: lhs._denominator * rhs._denominator)
    }
    public static func - (lhs: Fraction, rhs: Fraction) -> Fraction {

        return Fraction(num: lhs._numerator * rhs._denominator - rhs._numerator * lhs._denominator,
                        den: lhs._denominator * rhs._denominator)
    }
    public static func * (lhs: Fraction, rhs: Fraction) -> Fraction {

        return Fraction(num: lhs._numerator * rhs._numerator,
                        den: lhs._denominator * rhs._denominator)
    }
    public static func / (lhs: Fraction, rhs: Fraction) -> Fraction {
        precondition(rhs._numerator != 0, "Cannot divide by 0")

        return Fraction(num: lhs._numerator * rhs._denominator,
                        den: lhs._denominator * rhs._numerator)
    }
    public static func ** (lhs: Fraction, rhs: Fraction) -> Fraction {

        return Fraction(num: Int(pow(Double(lhs._numerator), rhs.decimal)),
                        den: Int(pow(Double(lhs._denominator), rhs.decimal)))

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
    public static func **= (lhs: inout Fraction, rhs: Fraction) {
        lhs = lhs ** rhs
    }

}
extension Fraction: SignedNumeric {
    public mutating func negate() {
        self._numerator = -self._numerator
    }
}
extension Fraction: Strideable {
    public typealias Stride = Fraction

    public func distance(to other: Fraction) -> Fraction {
        return other - self
    }

    public func advanced(by n: Fraction) -> Fraction {
        return self + n
    }
}

// Additional Operators (equality, comparison, arithmetic)
extension Fraction {

    // Equality operators with Int, Double, and Float
    public static func == (lhs: Fraction, rhs: Double) -> Bool {
        return lhs.decimal == rhs
    }
    public static func == (lhs: Fraction, rhs: Float) -> Bool {
        return Float(lhs.decimal) == rhs
    }
    public static func == (lhs: Fraction, rhs: Int) -> Bool {
        return (lhs._numerator == 0 && rhs == 0) || (lhs._denominator == 1 && lhs._numerator == rhs)
    }

    public static func == (lhs: Double, rhs: Fraction) -> Bool {
        return lhs == rhs.decimal
    }
    public static func == (lhs: Float, rhs: Fraction) -> Bool {
        return lhs == Float(rhs.decimal)
    }
    public static func == (lhs: Int, rhs: Fraction) -> Bool {
        return (rhs._numerator == 0 && lhs == 0) || (rhs._denominator == 1 && rhs._numerator == lhs)
    }

    // Comparison operators with Double
    public static func <  (lhs: Fraction, rhs: Double) -> Bool {
        return lhs.decimal < rhs
    }
    public static func > (lhs: Fraction, rhs: Double) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Fraction, rhs: Double) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Fraction, rhs: Double) -> Bool {
        return !(lhs < rhs)
    }

    public static func <  (lhs: Double, rhs: Fraction) -> Bool {
        return lhs < rhs.decimal
    }
    public static func > (lhs: Double, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Double, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Double, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    // Comparison operators with Int
    public static func <  (lhs: Fraction, rhs: Int) -> Bool {
        return lhs.decimal < Double(rhs)
    }
    public static func > (lhs: Fraction, rhs: Int) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Fraction, rhs: Int) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Fraction, rhs: Int) -> Bool {
        return !(lhs < rhs)
    }

    public static func <  (lhs: Int, rhs: Fraction) -> Bool {
        return Double(lhs) < rhs.decimal
    }
    public static func > (lhs: Int, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Int, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Int, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    // Comparison operators with Float
    public static func <  (lhs: Fraction, rhs: Float) -> Bool {
        return Float(lhs.decimal) < rhs
    }
    public static func > (lhs: Fraction, rhs: Float) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Fraction, rhs: Float) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Fraction, rhs: Float) -> Bool {
        return !(lhs < rhs)
    }

    public static func <  (lhs: Float, rhs: Fraction) -> Bool {
        return lhs < Float(rhs.decimal)
    }
    public static func > (lhs: Float, rhs: Fraction) -> Bool {
        return !(lhs <= rhs)
    }
    public static func <= (lhs: Float, rhs: Fraction) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    public static func >= (lhs: Float, rhs: Fraction) -> Bool {
        return !(lhs < rhs)
    }

    // Arithmetic operators with Int
    public static func + (lhs: Fraction, rhs: Int) -> Fraction {

        return Fraction(num: lhs._numerator + (rhs * lhs._denominator),
                        den: lhs._denominator)

    }
    public static func - (lhs: Fraction, rhs: Int) -> Fraction {

        return Fraction(num: lhs._numerator - rhs * lhs._denominator,
                        den: lhs._denominator)

    }
    public static func * (lhs: Fraction, rhs: Int) -> Fraction {

        return Fraction(num: lhs._numerator * rhs,
                        den: lhs._denominator)

    }
    public static func / (lhs: Fraction, rhs: Int) -> Fraction {
        precondition(rhs != 0, "Cannot divide by 0")

        return Fraction(num: lhs._numerator,
                        den: lhs._denominator * rhs)

    }
    public static func ** (lhs: Fraction, rhs: Int) -> Fraction {
        return Fraction(num: Int(pow(Double(lhs._numerator), Double(rhs))),
                        den: Int(pow(Double(lhs._denominator), Double(rhs))))
    }

    public static func + (lhs: Int, rhs: Fraction) -> Fraction {

        return Fraction(num: lhs * rhs._denominator + rhs._numerator,
                        den: rhs._denominator)

    }
    public static func - (lhs: Int, rhs: Fraction) -> Fraction {

        return Fraction(num: lhs * rhs._denominator - rhs._numerator,
                        den: rhs._denominator)

    }
    public static func * (lhs: Int, rhs: Fraction) -> Fraction {

        return Fraction(num: lhs * rhs._numerator,
                        den: rhs._denominator)

    }
    public static func / (lhs: Int, rhs: Fraction) -> Fraction {
        precondition(rhs._numerator != 0, "Cannot divide by 0")

        return Fraction(num: lhs * rhs._denominator,
                        den: rhs._numerator)
    }

    public static func += (lhs: inout Fraction, rhs: Int) {
        lhs = lhs + rhs
    }
    public static func -= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs - rhs
    }
    public static func *= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs * rhs
    }
    public static func /= (lhs: inout Fraction, rhs: Int) {
        lhs = lhs / rhs
    }
    public static func **= (lhs: inout Fraction, rhs: Int) {
        return lhs = lhs ** rhs
    }

    // Arithmetic operators with Double
    public static func + (lhs: Fraction, rhs: Double) -> Fraction {

        return lhs + Fraction(rhs)

    }
    public static func - (lhs: Fraction, rhs: Double) -> Fraction {

        return lhs - Fraction(rhs)

    }
    public static func * (lhs: Fraction, rhs: Double) -> Fraction {

        return lhs * Fraction(rhs)

    }
    public static func / (lhs: Fraction, rhs: Double) -> Fraction {
        precondition(rhs != 0.0, "Cannot divide by 0")

        return lhs / Fraction(rhs)

    }
    public static func ** (lhs: Fraction, rhs: Double) -> Fraction {
        return Fraction(num: Int(pow(Double(lhs._numerator), rhs)),
                        den: Int(pow(Double(lhs._denominator), rhs)))
    }

    public static func + (lhs: Double, rhs: Fraction) -> Fraction {

        return Fraction(lhs) + rhs

    }
    public static func - (lhs: Double, rhs: Fraction) -> Fraction {

        return Fraction(lhs) - rhs

    }
    public static func * (lhs: Double, rhs: Fraction) -> Fraction {

        return Fraction(lhs) * rhs

    }
    public static func / (lhs: Double, rhs: Fraction) -> Fraction {
        precondition(rhs._numerator != 0, "Cannot divide by 0")

        return Fraction(lhs) / rhs
    }

    public static func += (lhs: inout Fraction, rhs: Double) {
        lhs = lhs + rhs
    }
    public static func -= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs - rhs
    }
    public static func *= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs * rhs
    }
    public static func /= (lhs: inout Fraction, rhs: Double) {
        lhs = lhs / rhs
    }
    public static func **= (lhs: inout Fraction, rhs: Double) {
        return lhs = lhs ** rhs
    }

    // Arithmetic operators with Float
    public static func + (lhs: Fraction, rhs: Float) -> Fraction {

        return lhs + Fraction(rhs)

    }
    public static func - (lhs: Fraction, rhs: Float) -> Fraction {

        return lhs - Fraction(rhs)

    }
    public static func * (lhs: Fraction, rhs: Float) -> Fraction {

        return lhs * Fraction(rhs)

    }
    public static func / (lhs: Fraction, rhs: Float) -> Fraction {
        precondition(rhs != 0.0, "Cannot divide by 0")

        return lhs / Fraction(rhs)

    }
    public static func ** (lhs: Fraction, rhs: Float) -> Fraction {
        return Fraction(num: Int(pow(Double(lhs._numerator), Double(rhs))),
                        den: Int(pow(Double(lhs._denominator), Double(rhs))))
    }

    public static func + (lhs: Float, rhs: Fraction) -> Fraction {

        return Fraction(lhs) + rhs

    }
    public static func - (lhs: Float, rhs: Fraction) -> Fraction {

        return Fraction(lhs) - rhs

    }
    public static func * (lhs: Float, rhs: Fraction) -> Fraction {

        return Fraction(lhs) * rhs

    }
    public static func / (lhs: Float, rhs: Fraction) -> Fraction {
        precondition(rhs._numerator != 0, "Cannot divide by 0")

        return Fraction(lhs) / rhs
    }

    public static func += (lhs: inout Fraction, rhs: Float) {
        lhs = lhs + rhs
    }
    public static func -= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs - rhs
    }
    public static func *= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs * rhs
    }
    public static func /= (lhs: inout Fraction, rhs: Float) {
        lhs = lhs / rhs
    }
    public static func **= (lhs: inout Fraction, rhs: Float) {
        return lhs = lhs ** rhs
    }
}

extension Fraction {
    /// The reciprocal of the fraction.
    public var reciprocal: Fraction {
        get {
            return Fraction(num: denominator, den: numerator)
        }
    }

    /// `true` iff `self` is neither infinite nor NaN
    public var isFinite: Bool {
        return denominator != 0
    }

    /// `true` iff the numerator is zero and the denominator is nonzero
    public var isInfinite: Bool {
        return denominator == 0 && numerator != 0
    }

    /// `true` iff both the numerator and the denominator are zero
    public var isNaN: Bool {
        return denominator == 0 && numerator == 0
    }

    /// The positive infinity.
    public static var infinity: Fraction {
        return Fraction(num: 1, den: 0)
    }

    /// Not a number.
    public static var NaN: Fraction {
        return Fraction(num: 0, den: 0)
    }
}

// Extensions of numeric types to integrate Fraction
public extension Int {
    init (_ fraction: Fraction) {
        self = fraction.numerator / fraction.denominator
    }
}
public extension Double {
    init (_ fraction: Fraction) {
        self = Double(fraction.numerator) / Double(fraction.denominator)
    }

    static func += (lhs: inout Double, rhs: Fraction) {
        lhs = lhs + rhs.decimal
    }
    static func -= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs - rhs.decimal
    }
    static func *= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs * rhs.decimal
    }
    static func /= (lhs: inout Double, rhs: Fraction) {
        lhs = lhs / rhs.decimal
    }

}
public extension Float {
    init (_ fraction: Fraction) {
        self = Float(fraction.numerator) / Float(fraction.denominator)
    }
}
