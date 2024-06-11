import XCTest
@testable import SwiftUILintExecutable

final class SimplifyDiagnoserTests: DiagnoserTestCase<SimplifyDiagnoser> {

    func testClipShape() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .clipShape(1️⃣Circle())
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Consider using '.circle' instead")

    }
    
    func testStyles() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .buttonStyle(1️⃣BorderedButtonStyle())
                    .pickerStyle(2️⃣InlinePickerStyle())
                    .listStyle(3️⃣GroupedListStyle())
                    .labelStyle(4️⃣IconOnlyLabelStyle())
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 4)

        XCTAssertEqual(diagnostics("1️⃣"), "Consider using '.bordered' instead")
        XCTAssertEqual(diagnostics("2️⃣"), "Consider using '.inline' instead")
        XCTAssertEqual(diagnostics("3️⃣"), "Consider using '.grouped' instead")
        XCTAssertEqual(diagnostics("4️⃣"), "Consider using '.iconOnly' instead")

    }

}
