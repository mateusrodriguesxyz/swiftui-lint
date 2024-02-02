import XCTest
@testable import PluginExecutable

final class ImageDiagnoserTests: DiagnoserTestCase<ImageDiagnoser> {

    func testInvalidSystemSymbol() throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image(systemName: "xyz")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "There's no system symbol named 'xyz'")

    }

    func testMissingResizable() throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image("xyz")
                    .scaledToFit()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'resizable' modifier")

    }

    func testResizable() throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image("xyz")
                    .resizable()
                    .scaledToFit()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }


}
