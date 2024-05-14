import XCTest
import SwiftParser
import SwiftSyntax
@testable import SwiftUILintExecutable

final class PropertyCollectorTests: XCTestCase {

    func testCollect() {

        let source = """
        struct T {

            let a = 1
            let b = 2
            let c = 3

            func foo() {
                let d = ""
            }

            struct ST1 {
                let d = ""
            }

            class ST2 {
                let d = ""
            }

            actor ST3 {
                let d = ""
            }

            enum ST4 {
                static var d = ""
            }

        }
        """

        let node = Parser.parse(source: source).descendant(StructDeclSyntax.self)!

        let properties = PropertyCollector(node).properties

        XCTAssertEqual(properties.count, 3)

    }

}
