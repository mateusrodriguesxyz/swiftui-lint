import XCTest
@testable import PluginExecutable

final class ImageDiagnoserTests: DiagnoserTestCase<ImageDiagnoser> {

    func testInvalidSystemSymbol() {

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

    func testMissingResizable() {

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

    func testResizable() {

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
    
    func testResizableNonTriggering() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    Text(order.id)
                    Image.donutSymbol
                    Text(order.totalSales.formatted())
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(pulseOrderText ? .primary : .secondary)
                .fontWeight(pulseOrderText ? .bold : .regular)
                .contentTransition(.interpolate)
            }
        }
        """
        
        test(source)

        XCTAssertEqual(count, 0)
        
    }


}
