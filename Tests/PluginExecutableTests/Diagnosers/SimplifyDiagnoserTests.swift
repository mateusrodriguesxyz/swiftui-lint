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

        XCTAssertEqual(diagnostic.message, "Consider using '.circle' for simplicity")

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

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Consider using '.bordered' for simplicity")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Consider using '.inline' for simplicity")
        XCTAssertEqual(diagnoser.diagnostics[2].message, "Consider using '.grouped' for simplicity")
        XCTAssertEqual(diagnoser.diagnostics[3].message, "Consider using '.iconOnly' for simplicity")

    }

}
