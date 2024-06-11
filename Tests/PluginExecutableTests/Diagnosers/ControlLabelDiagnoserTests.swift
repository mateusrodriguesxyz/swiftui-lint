import XCTest
@testable import SwiftUILintExecutable

final class ControlLabelDiagnoserTests: DiagnoserTestCase<ControlLabelDiagnoser> {

    func testControlLabelWithAnotherLabel() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Button {

                } label: {
                    1️⃣Button("") { }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'Button' should not be placed inside 'Button' label")

    }
    
    func testControlLabelWithImage1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Button {

                } label: {
                    1️⃣Image(systemImage: "")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use 'Button(_:systemImage:action:)' or 'Label(_:systemImage:)' to provide an accessibility label")

    }
    
    func testControlLabelWithImage2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationLink {

                } label: {
                    1️⃣Image(systemImage: "")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use 'Label(_:systemImage:)' to provide an accessibility label")

    }
    
    func testControlEmptyLabel() {
    
        
        let source = """
        struct ContentView: View {
            var body: some View {
                Stepper("1️⃣", value: .constant(0))
            }
        }
        """
        
        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Consider providing a non-empty label for accessibility purpose and using 'labelsHidden' modifier to omit it in the user interface")
        
    }
    
    func testListRowWithButtons() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                List {
                    ForEach(0..<5) { _ in
                        VStack {
                            Button("Button 1") { }
                            Button("Button 2") { }
                        }1️⃣
                    }
                }
            }
        }
        """
        
        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Apply 'buttonStyle(.borderless)' modifier to disable the default row tap behavior")
        
    }

}
