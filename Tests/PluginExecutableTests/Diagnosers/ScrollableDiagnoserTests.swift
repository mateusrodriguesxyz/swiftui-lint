import XCTest
@testable import SwiftUILintExecutable

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
                ScrollView {
                    HStack {
        
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostic.message, "Use 'ScrollView(.horizontal)' to match 'HStack'")

    }

}
