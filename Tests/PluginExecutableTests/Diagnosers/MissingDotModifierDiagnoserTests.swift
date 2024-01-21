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
                            padding()
                    }
                    padding()
            }

            @ViewBuilder
            func content() -> some View {
                EmptyView()
                    padding()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)

        XCTAssertEqual(diagnostic.message, "Missing 'padding' leading dot")

    }

}
