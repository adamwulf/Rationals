//
//  File.swift
//  
//
//  Created by Adam Wulf on 5/13/21.
//

import Foundation

struct RationalArray<Element> {

    private let range = Fraction.zero ..< Fraction.one
    private var elements: [(index: Fraction, value: Element)] = []

    var indices: [Fraction] {
        return elements.map({ $0.index })
    }

    mutating func append(_ item: Element) {
        if let lastElement = elements.last {
            elements.append((index: (lastElement.index + range.upperBound) / 2, value: item))
        } else {
            elements.append((index: (range.lowerBound + range.upperBound) / 2, value: item))
        }
    }

    mutating func insert(_ item: Element, at index: Fraction) {
        let arrIndex = elements.firstIndex { element in
            element.index >= index
        }
        guard let arrIndex = arrIndex else {
            append(item)
            return
        }
        if elements[arrIndex].index == index {
            let prevIndex = arrIndex > 0 ? elements[arrIndex - 1].index : range.lowerBound
            let avgIndex = (prevIndex + index) / 2
            elements.insert((index: avgIndex, value: item), at: arrIndex)
        } else {
            elements.insert((index: index, value: item), at: arrIndex)
        }
    }

    mutating func append(contentsOf items: [Element]) {
        items.forEach({ self.append($0) })
    }

    mutating func remove(at index: Fraction) {
        let arrIndex = elements.firstIndex { element in
            element.index >= index
        }
        guard let arrIndex = arrIndex else { return }
        elements.remove(at: arrIndex)
    }
}

extension RationalArray: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element

    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self.append(contentsOf: elements)
    }
}

extension RationalArray where Element: Comparable {
    mutating func remove(item: Element) {
        while true {
            let arrIndex = elements.firstIndex { element in
                element.value == item
            }
            guard let arrIndex = arrIndex else { return }
            elements.remove(at: arrIndex)
        }
    }
}
