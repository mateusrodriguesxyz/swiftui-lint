import XCTest
import SwiftParser
import SwiftSyntax
@testable import SwiftUILintExecutable

final class ChildrenCollectorTests: XCTestCase {

    func test() {

        let source = """
        Group {
            Child1()
            Child2()
            if true {
                Child3()
                Child4()
            }
            switch Bool.random() {
                case true:
                    Child5()
                case false:
                    Child6()
                    Child7()
            }
            #if os(iOS)
            Child8()
            Child9()
            #endif
            Child10()
        }
        """

        let node = Parser.parse(source: source)

        let collector = ChildrenCollector(node)

        XCTAssertEqual(collector.children.count, 10)

    }


}
