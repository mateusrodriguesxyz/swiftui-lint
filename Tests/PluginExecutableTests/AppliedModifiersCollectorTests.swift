import XCTest
import SwiftParser
import SwiftSyntax
@testable import SwiftUILintExecutable

final class AppliedModifiersCollectorTests: XCTestCase {

    
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

        let children = ChildrenCollector(node).children.compactMap { ViewChildWrapper($0) }


        XCTAssertEqual(children.count, 3)

        XCTAssertEqual(AllAppliedModifiersCollector(children[0].node).matches.count, 1)
        XCTAssertEqual(AllAppliedModifiersCollector(children[1].node).matches.count, 2)
        XCTAssertEqual(AllAppliedModifiersCollector(children[2].node).matches.count, 3)
    }

}
