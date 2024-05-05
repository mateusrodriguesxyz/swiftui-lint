import XCTest
@testable import SwiftUILintExecutable

final class SimplifyDiagnoserTests: DiagnoserTestCase<SimplifyDiagnoser> {

    func testClipShape() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .clipShape(Circle())
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use '.circle' to simplify your code")

    }
    
    func testStyles() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .buttonStyle(BorderedButtonStyle())
                    .pickerStyle(InlinePickerStyle())
                    .listStyle(GroupedListStyle())
                    .labelStyle(IconOnlyLabelStyle())
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 4)

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Use '.bordered' to simplify your code")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Use '.inline' to simplify your code")
        XCTAssertEqual(diagnoser.diagnostics[2].message, "Use '.grouped' to simplify your code")
        XCTAssertEqual(diagnoser.diagnostics[3].message, "Use '.iconOnly' to simplify your code")

    }

}
