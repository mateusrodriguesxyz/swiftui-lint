import XCTest
@testable import PluginExecutable

final class SheetDiagnoserTests: DiagnoserTestCase<SheetDiagnoser> {

    func testUngroupedChildren() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .sheet(isPresented: .constant(true)) {
                        Text("")
                        Image("")
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use a container view to group 'Text' and 'Image'")

    }

    func testUnnecessaryIsPresentedBinding1() {

        let source = """
        struct ContentView: View {
        
            @State private var isPresented = true

            var body: some View {
                EmptyView()
                    .sheet(isPresented: $isPresented) {
                        SheetContent(isPresented: $isPresented)
                    }
                    .sheet(isPresented: $isPresented) {
                        EmptyView()
                            #if os(macOS)
                            .frame(minWidth: 400, minHeight: 400)
                            #endif
                    }
            }
        }

        struct SheetContent: View {
            @Binding var isPresented: Bool
            var body: some View {
                Button("Dismiss") {
                    isPresented = false
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Dismiss 'SheetContent' using environment 'DismissAction' instead")

    }

    func testUnnecessaryIsPresentedBinding2() {

        let source = """
        struct ContentView: View {

            @State private var isPresented = true

            var body: some View {
                EmptyView()
                    .sheet(isPresented: $isPresented) {
                        SheetContent(isPresented: $isPresented)
                            #if os(macOS)
                            .frame(minWidth: 400, minHeight: 400)
                            #endif
                    }
            }
        }

        struct SheetContent: View {
            @Binding var isPresented: Bool
            var body: some View {
                Button("Dismiss") {
                    isPresented = false
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Dismiss 'SheetContent' using environment 'DismissAction' instead")

    }

}
