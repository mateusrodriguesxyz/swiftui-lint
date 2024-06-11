import XCTest
@testable import SwiftUILintExecutable

final class ScrollableDiagnoserTests: DiagnoserTestCase<ScrollableDiagnoser> {

    func testMissingScrollContentBackground() {

        let source = """
        struct ContentView: View {
            var body: some View {
                List {
        
                }
                .1️⃣background(.blue)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'scrollContentBackground(.hidden)' modifier")

    }
    
    func testMissingScrollContentBackgroundNonTriggering() {

        let source = """
        struct ContentView: View {
            var body: some View {
                List {
        
                }
                .scrollContentBackground(.hidden)
                .background(.blue)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    func testScrollViewHStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣ScrollView {
                    HStack {
        
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "Use 'ScrollView(.horizontal)' to match 'HStack'")

    }

}
