import XCTest
@testable import Rationals

final class RationalArrayTests: XCTestCase {

    struct ModelObject {
        public var val: String
    }

    func testAppendIndices() {
        var arr: RationalArray = [ModelObject(val: "fumble")]

        XCTAssertEqual(arr.indices, [Fraction(num: 1, den: 2)])

        arr.append(ModelObject(val: "bumble"))

        // Indices are mediants toward 1: 1/2, 2/3, 3/4, ...
        XCTAssertEqual(arr.indices, [Fraction(num: 1, den: 2), Fraction(num: 2, den: 3)])
        XCTAssertEqual(arr.values.map({ $0.val }), ["fumble", "bumble"])
        XCTAssertEqual(arr.count, 2)
        XCTAssertFalse(arr.isEmpty)
    }

    func testManyAppendsDoNotOverflow() {
        // Mediant indices grow denominators linearly, so long append runs
        // must neither trap nor produce out-of-order indices.
        var arr = RationalArray<Int>()
        for i in 0..<1000 {
            arr.append(i)
        }
        XCTAssertEqual(arr.count, 1000)
        XCTAssertEqual(arr.values, Array(0..<1000))
        let indices = arr.indices
        for i in 1..<indices.count {
            XCTAssertTrue(indices[i - 1] < indices[i], "indices must strictly increase at \(i)")
        }
        XCTAssertTrue(indices.last! < Fraction.one)
    }

    func testValueAtIndex() {
        var arr = RationalArray<String>()
        arr.append("a")
        arr.append("b")

        XCTAssertEqual(arr.value(at: Fraction(num: 1, den: 2)), "a")
        XCTAssertEqual(arr.value(at: Fraction(num: 2, den: 3)), "b")
        XCTAssertNil(arr.value(at: Fraction(num: 1, den: 3)))
    }

    func testInsertBetween() {
        var arr = RationalArray<String>()
        arr.append("a")            // 1/2
        arr.append("c")            // 2/3
        arr.insert("b", at: Fraction(num: 7, den: 12))  // between 1/2 and 2/3

        XCTAssertEqual(arr.values, ["a", "b", "c"])
        XCTAssertEqual(arr.value(at: Fraction(num: 7, den: 12)), "b")
    }

    func testInsertAtTakenIndex() {
        var arr = RationalArray<String>()
        arr.append("b")            // 1/2
        arr.insert("a", at: Fraction(num: 1, den: 2))

        // The new item slots in just before the existing one.
        XCTAssertEqual(arr.values, ["a", "b"])
        XCTAssertEqual(arr.value(at: Fraction(num: 1, den: 2)), "b")
        XCTAssertEqual(arr.value(at: Fraction(num: 1, den: 3)), "a")
    }

    func testInsertPastEndHonorsIndex() {
        var arr = RationalArray<String>()
        arr.append("a")            // 1/2
        arr.insert("b", at: Fraction(num: 9, den: 10))

        XCTAssertEqual(arr.values, ["a", "b"])
        XCTAssertEqual(arr.indices, [Fraction(num: 1, den: 2), Fraction(num: 9, den: 10)])
    }

    func testRemoveAtExactIndexOnly() {
        var arr = RationalArray<String>()
        arr.append("a")            // 1/2
        arr.append("b")            // 2/3

        // No element has this index: removal is a no-op, not a fuzzy match.
        arr.remove(at: Fraction(num: 1, den: 3))
        XCTAssertEqual(arr.count, 2)

        arr.remove(at: Fraction(num: 1, den: 2))
        XCTAssertEqual(arr.values, ["b"])
    }

    func testRemoveItemRemovesAllMatches() {
        var arr: RationalArray = ["a", "b", "a", "c"]
        arr.remove(item: "a")

        XCTAssertEqual(arr.values, ["b", "c"])

        arr.remove(item: "missing")
        XCTAssertEqual(arr.values, ["b", "c"])
    }
}
