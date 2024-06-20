import XCTest
@testable import SwiftUILintExecutable

final class ImageDiagnoserTests: DiagnoserTestCase<ImageDiagnoser> {

    func testInvalidSystemSymbol() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image(systemName: "1️⃣xyz")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "There's no system symbol named 'xyz'")

    }

    func testMissingResizable() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image("xyz", label: Text(""))
                    .1️⃣scaledToFit()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'resizable' modifier")

    }

    func testResizable() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Image("xyz", label: Text(""))
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
                Image.picture
            }
        }
        """
        
        test(source)

        XCTAssertEqual(count, 0)
        
    }
    
    func testImageWithoutLabel1() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣Image("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Apply 'accessibilityLabel' modifier to provide a label or 'accessibilityHidden(true)' to ignore it for accessibility purpose")

    }
    
    func testImageWithoutLabelNonTriggering() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                Image(decorative: "")
                Image("", label: Text(""))
                Image("")
                    .accessibilityLabel(Text(""))
                Image("")
                    .accessibilityHidden(true)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)
        
    }


}
