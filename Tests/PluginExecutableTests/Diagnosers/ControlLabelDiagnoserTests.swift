import XCTest
@testable import SwiftUILintExecutable

final class ControlLabelDiagnoserTests: DiagnoserTestCase<ControlLabelDiagnoser> {

    func testControlLabelWithAnotherLabel() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Button {

                } label: {
                    Button("") { }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'Button' should not be placed inside 'Button' label")

    }


}
