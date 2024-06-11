import XCTest
@testable import SwiftUILintExecutable

final class ToolbarDiagnoserTests: DiagnoserTestCase<ToolbarDiagnoser> {

    func testToolbarItemWithMoreThanOneChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        1️⃣ToolbarItem {
                            Button("1") { }
                            Button("2") { }
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Group 'Button' and 'Button' using 'ToolbarItemGroup' instead")

    }

    func testToolbarItemWithStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        1️⃣ToolbarItem {
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

        XCTAssertEqual(diagnostics("1️⃣"), "Group 'Button' and 'Button' using 'ToolbarItemGroup' instead")

    }


}
