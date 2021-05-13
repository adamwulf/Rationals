import XCTest
@testable import Rationals

final class RationalArrayTests: XCTestCase {

    struct ModelObject {
        public var val: String
    }

    func testRationalArray() {
        var arr: RationalArray = [ModelObject(val: "fumble")]

        XCTAssertEqual(arr.indices, [Fraction(num: 1, den: 2)])

        arr.append(ModelObject(val: "bumble"))

        XCTAssertEqual(arr.indices, [Fraction(num: 1, den: 2), Fraction(num: 3, den: 4)])
    }

}
