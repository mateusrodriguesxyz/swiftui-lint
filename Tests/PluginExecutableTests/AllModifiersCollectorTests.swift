import XCTest
import SwiftParser
import SwiftSyntax
@testable import PluginExecutable

final class AllModifiersCollectorTests: XCTestCase {

    func testRun() async throws {

        let source = """
        Group {
            EmptyView()
                .overlay {
                    EmptyView()
                        .padding()
                        .padding()
                }
            EmptyView()
                .padding()
                .padding()
            VStack {

            }
            .padding()
            .padding()
            .onAppear { }
        }
        """

        let node = Parser.parse(source: source)

        let children = ChildrenCollector(node).children.map { ViewChildWrapper(node: $0) }


        XCTAssertEqual(children.count, 3)

        XCTAssertEqual(AllModifiersCollector(children[0].node).matches.count, 1)
        XCTAssertEqual(AllModifiersCollector(children[1].node).matches.count, 2)
        XCTAssertEqual(AllModifiersCollector(children[2].node).matches.count, 3)
    }

}