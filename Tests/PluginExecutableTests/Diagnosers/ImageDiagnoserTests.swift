import XCTest
@testable import SwiftUILintExecutable

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
                Image("xyz", label: Text(""))
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
                Image("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Apply 'accessibilityLabel' modifier to provide a label or 'accessibilityHidden(true)' to ignore it for accessibility purposes")

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
