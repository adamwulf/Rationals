# Rationals

A Swift `Fraction` type: exact rational arithmetic backed by `Int`
numerator/denominator, with total (never-trapping) conversion from `Double`.

Based on Noah Wilder's Fraction package at
https://github.com/Wildchild9/SwiftFractions and Jaden Geller's package at
https://github.com/JadenGeller/Fractional.

## Usage

```swift
import Rationals

// Exact arithmetic from integers
let third = Fraction(num: 1, den: 3)
let ninth = third * third               // exactly 1/9
let sum = third + Fraction(num: 1, den: 6)   // exactly 1/2

// Fractions are always reduced and sign-normalized
Fraction(num: 2, den: -4)               // -1/2, signum == -1

// Literals work too
let half: Fraction = 0.5                // 1/2
let two: Fraction = 2                   // 2/1

// Total conversion from Double — never traps
Fraction(1.0 / 3.0)                     // 3333333333333333/10^16
Fraction(Double.nan)                    // Fraction.NaN
Fraction(1e20)                          // saturates near Int.max

// Exactness-honest conversions return nil instead of approximating
Fraction(exactly: 0.5)                  // 1/2
Fraction(exactly: 1e-13)                // nil (no exact decimal form)
Int(exactly: Fraction(num: 4, den: 2))  // 2
Int(exactly: Fraction(num: 7, den: 2))  // nil (not a whole number)
```

## Semantics worth knowing

- **Comparison is exact.** `<` cross-multiplies in 128 bits, so fractions
  that differ beyond `Double` precision still order correctly.
- **Arithmetic is total.** `+`, `-`, `*`, `/` never trap: when an exact
  result would overflow `Int`, the result degrades to the closest
  representable fraction (via the total `Double` conversion path).
- **Non-finite values follow IEEE rules.** `1/0` is `Fraction.infinity`,
  `0/0` is `Fraction.NaN`; `inf + inf == inf`, `inf - inf` is NaN, and NaN
  compares false under `<`, `>`, `<=`, `>=`. One deliberate exception:
  equality is structural, so `Fraction.NaN == Fraction.NaN` is `true`,
  which keeps `Equatable`/`Hashable` sane in collections.
- **Mixed-type operators exist for `Int`, `Double`, and `Float`.** Beware
  that Swift may resolve a *literal* operand to the homogeneous
  `Fraction` operator instead (converting the literal through
  `Fraction(Double)`); use typed variables when the distinction matters.

## Installation

Add to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/adamwulf/Rationals", from: "1.0.0"),
```

## Testing

```sh
swift test
swift test -c release
```

The release-mode run matters: the package guards against a Swift
overload-resolution hazard (`FractionDoubleInitRegressionTests`) that only
manifested in optimized builds.
