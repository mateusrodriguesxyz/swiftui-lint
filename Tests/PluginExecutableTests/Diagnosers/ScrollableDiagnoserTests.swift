import XCTest
@testable import PluginExecutable

final class ScrollableDiagnoserTests: DiagnoserTestCase<ScrollableDiagnoser> {

    func testMissingScrollContentBackground() {

        let source = """
        struct ContentView: View {
            var body: some View {
                List {
        
                }
                .background(.blue)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'scrollContentBackground(.hidden)' modifier")

    }

}
