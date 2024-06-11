import XCTest
@testable import SwiftUILintExecutable

final class MissingDotModifierDiagnoserTests: DiagnoserTestCase<MissingDotModifierDiagnoser> {

    func testPadding() {

        let source = """
        struct ContentView: View {

            var body: some View {
                EmptyView()
                    .overlay {
                        EmptyView()
                            1️⃣padding()
                    }
                    2️⃣padding()
            }

            @ViewBuilder
            func content() -> some View {
                EmptyView()
                    3️⃣padding()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)

        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'padding' leading dot")
        XCTAssertEqual(diagnostics("2️⃣"), "Missing 'padding' leading dot")
        XCTAssertEqual(diagnostics("3️⃣"), "Missing 'padding' leading dot")

    }

}
