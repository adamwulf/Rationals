//
//  RationalArray.swift
//
//
//  Created by Adam Wulf on 5/13/21.
//

import Foundation

/// An ordered collection whose elements are addressed by `Fraction` indices
/// strictly between 0 and 1, so an element can always be inserted between two
/// existing elements without renumbering anything.
///
/// New indices are chosen as the *mediant* of their neighbors' indices
/// (`(a + c) / (b + d)` for `a/b` and `c/d`), which is always strictly between
/// them and grows denominators additively — appending N elements needs a
/// denominator of only N+1, not 2^N.
struct RationalArray<Element> {

    private static var lowerBound: Fraction { Fraction.zero }
    private static var upperBound: Fraction { Fraction.one }

    private var elements: [(index: Fraction, value: Element)] = []

    var indices: [Fraction] {
        return elements.map({ $0.index })
    }

    var values: [Element] {
        return elements.map({ $0.value })
    }

    var count: Int {
        return elements.count
    }

    var isEmpty: Bool {
        return elements.isEmpty
    }

    /// The value stored at exactly `index`, or nil if no element has that index.
    func value(at index: Fraction) -> Element? {
        return elements.first(where: { $0.index == index })?.value
    }

    /// The mediant (a+c)/(b+d) of two fractions, which for a/b < c/d always
    /// lies strictly between them.
    private static func mediant(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
        return Fraction(num: lhs.numerator + rhs.numerator,
                        den: lhs.denominator + rhs.denominator)
    }

    mutating func append(_ item: Element) {
        let lastIndex = elements.last?.index ?? Self.lowerBound
        elements.append((index: Self.mediant(lastIndex, Self.upperBound), value: item))
    }

    /// Inserts `item` at `index`, which must lie strictly between 0 and 1.
    /// If the index is already taken, the new item lands just before the
    /// existing element (at the mediant of the two surrounding indices).
    mutating func insert(_ item: Element, at index: Fraction) {
        let arrIndex = elements.firstIndex { element in
            element.index >= index
        }
        guard let arrIndex = arrIndex else {
            // Every existing index is smaller, so the requested index can be
            // stored at the end as-is.
            elements.append((index: index, value: item))
            return
        }
        if elements[arrIndex].index == index {
            // The requested index is taken: slot the new item just before it,
            // between its previous neighbor and the existing element.
            let prevIndex = arrIndex > 0 ? elements[arrIndex - 1].index : Self.lowerBound
            elements.insert((index: Self.mediant(prevIndex, index), value: item), at: arrIndex)
        } else {
            elements.insert((index: index, value: item), at: arrIndex)
        }
    }

    mutating func append(contentsOf items: [Element]) {
        items.forEach({ self.append($0) })
    }

    /// Removes the element stored at exactly `index`; does nothing if no
    /// element has that index.
    mutating func remove(at index: Fraction) {
        let arrIndex = elements.firstIndex { element in
            element.index == index
        }
        guard let arrIndex = arrIndex else { return }
        elements.remove(at: arrIndex)
    }
}

extension RationalArray: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element

    init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self.append(contentsOf: elements)
    }
}

extension RationalArray where Element: Equatable {
    /// Removes every element equal to `item`.
    mutating func remove(item: Element) {
        elements.removeAll(where: { $0.value == item })
    }
}
