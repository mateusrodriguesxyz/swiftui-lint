import XCTest
@testable import SwiftUILintExecutable

final class FrameDiagnoserTests: DiagnoserTestCase<FrameDiagnoser> {

    func testFrameInfinity() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .frame(width: .infinity, height: .infinity)
                    .background(.red)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Use 'maxWidth' instead")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Use 'maxHeight' instead")

    }
    
    func testLeadingFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    Text("")
                    Spacer()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostic.message, "Consider applying 'frame(maxWidth: .infinity, alignment: .leading)' modifier to 'Text' instead")

    }
    
    func testTrailingFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    Spacer()
                    Text("")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostic.message, "Consider applying 'frame(maxWidth: .infinity, alignment: .trailing)' modifier to 'Text' instead")

    }
    
    func testTopFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    Text("")
                    Spacer()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostic.message, "Consider applying 'frame(maxHeight: .infinity, alignment: .top)' modifier to 'Text' instead")

    }
    
    func testBottomFrame() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    Spacer()
                    Text("")
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostic.message, "Consider applying 'frame(maxHeight: .infinity, alignment: .bottom)' modifier to 'Text' instead")

    }

}
