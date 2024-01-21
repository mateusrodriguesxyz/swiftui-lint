import XCTest
@testable import SwiftUILintExecutable

final class ToolbarDiagnoserTests: DiagnoserTestCase<ToolbarDiagnoser> {

    func testToolbarItemWithMoreThanOneChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        ToolbarItem {
                            Button("1") { }
                            Button("2") { }
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Group 'Button' and 'Button' using 'ToolbarItemGroup' instead")

    }

    func testToolbarItemWithStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                Button("1") { }
                                Button("2") { }
                            }
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Group 'Button' and 'Button' using 'ToolbarItemGroup' instead")

    }


}
