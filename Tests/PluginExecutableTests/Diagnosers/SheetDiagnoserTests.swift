import XCTest
@testable import SwiftUILintExecutable

final class SheetDiagnoserTests: DiagnoserTestCase<SheetDiagnoser> {

    func testUngroupedChildren() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .sheet(isPresented: .constant(true)) 1️⃣{
                        Text("")
                        Image("")
                    }
                    .background(Color.red)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Use a container view to group 'Text' and 'Image'")

    }

    func testUnnecessaryIsPresentedBinding() {

        let source = """
        struct ContentView: View {
        
            @State private var isPresented = true

            var body: some View {
                EmptyView()
                    .sheet(isPresented: $isPresented) {
                        SheetContent(isPresented: $isPresented)
                    }
            }
        }

        struct SheetContent: View {
            @Binding var isPresented: Bool
            var body: some View {
                Button("Dismiss") {
                    1️⃣isPresented = false
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Dismiss 'SheetContent' using environment 'DismissAction' instead")

    }
    
    func testMisusedIsPresented() {

        let source = """
        struct ContentView: View {
        
            @State private var isPresented = true

            var body: some View {
                EmptyView()
                    .sheet(isPresented: $isPresented) {
                        SheetContent(isPresented: $isPresented)
                    }
            }
        }

        struct SheetContent: View {
            @Binding var isPresented: Bool
            var body: some View {
                Button("Dismiss") {
                    1️⃣isPresented = false
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Dismiss 'SheetContent' using environment 'DismissAction' instead")

    }

}
