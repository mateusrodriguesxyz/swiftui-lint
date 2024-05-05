import XCTest
@testable import SwiftUILintExecutable

final class DeprecatedDiagnoserTests: DiagnoserTestCase<DeprecatedDiagnoser> {

    func testNavigationView() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationView {
        
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'NavigationView' is deprecated; use 'NavigationStack' or 'NavigationSplitView' instead")

    }

    func testForegroundColor() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Circle()
                    .foregroundColor(.red)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'foregroundColor' is deprecated; use 'foregroundStyle' instead")

    }
    
    func testPresentationMode() {

        let source = """
        struct ContentView: View {
            
            @Environment(\\.presentationMode)
        
            var body: some View {
                
            }
        
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'presentationMode' is deprecated; use 'isPresented' or 'dismiss' instead")

    }

}
