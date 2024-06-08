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

        XCTAssertEqual(diagnostic.message, "Consider using '.circle' instead")

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

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Consider using '.bordered' instead")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Consider using '.inline' instead")
        XCTAssertEqual(diagnoser.diagnostics[2].message, "Consider using '.grouped' instead")
        XCTAssertEqual(diagnoser.diagnostics[3].message, "Consider using '.iconOnly' instead")

    }

}
