import XCTest
@testable import SwiftUILintExecutable

final class DeprecatedDiagnoserTests: DiagnoserTestCase<DeprecatedDiagnoser> {

    func testNavigationView() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣NavigationView {
        
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'NavigationView' is deprecated; use 'NavigationStack' or 'NavigationSplitView' instead")

    }

    func testForegroundColor() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Circle()
                    .1️⃣foregroundColor(.red)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'foregroundColor' is deprecated; use 'foregroundStyle' instead")

    }
    
    func testPresentationMode() {

        let source = """
        struct ContentView: View {
            
            1️⃣@Environment(\\.presentationMode)
        
            var body: some View {
                
            }
        
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'presentationMode' is deprecated; use 'isPresented' or 'dismiss' instead")

    }

}
