import XCTest
@testable import SwiftUILintExecutable

final class FrameDiagnoserTests: DiagnoserTestCase<FrameDiagnoser> {

    func testFrameInfinity() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .frame(1️⃣width: .infinity, 2️⃣height: .infinity)
                    .background(.red)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)

        XCTAssertEqual(diagnostics("1️⃣"), "Use 'maxWidth' instead")
        XCTAssertEqual(diagnostics("2️⃣"), "Use 'maxHeight' instead")

    }
    
    func testLeadingFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣HStack {
                    Text("")
                    Spacer()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "Consider applying 'frame(maxWidth: .infinity, alignment: .leading)' modifier to 'Text' instead")

    }
    
    func testTrailingFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣HStack {
                    Spacer()
                    Text("")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "Consider applying 'frame(maxWidth: .infinity, alignment: .trailing)' modifier to 'Text' instead")

    }
    
    func testTopFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣VStack {
                    Text("")
                    Spacer()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "Consider applying 'frame(maxHeight: .infinity, alignment: .top)' modifier to 'Text' instead")

    }
    
    func testBottomFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣VStack {
                    Spacer()
                    Text("")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "Consider applying 'frame(maxHeight: .infinity, alignment: .bottom)' modifier to 'Text' instead")

    }

}
