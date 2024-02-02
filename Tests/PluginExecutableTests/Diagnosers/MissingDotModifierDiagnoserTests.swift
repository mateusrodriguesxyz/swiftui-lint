import XCTest
@testable import PluginExecutable

final class MissingDotModifierDiagnoserTests: DiagnoserTestCase<MissingDotModifierDiagnoser> {

    func testPadding() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    padding()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'padding' leading dot")

    }

}
