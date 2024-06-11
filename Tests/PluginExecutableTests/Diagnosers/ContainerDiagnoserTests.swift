import XCTest
@testable import SwiftUILintExecutable

final class ContainerDiagnoserTests: DiagnoserTestCase<ContainerDiagnoser> {

    func testEmptyVStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣VStack {

                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'VStack' has no children; consider removing it")

    }

    func testVStackWithOnlyChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣VStack {
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'VStack' has only one child; consider using 'EmptyView' on its own")

    }
    
    func testVStackWithGroupChild() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    Group {
                        Circle()
                        Circle()
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)
   
    }

    func testNavigationStackWithMoreThanOneChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣NavigationStack {
                    Color.red
                    Color.green
                    Color.blue
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Use a container view to group 'Color', 'Color' and 'Color'")

    }

    func testNonTriggering() {

        let source = """
        struct ContentView: View {
            var body: some View {
                Group {
                    NavigationStack {
                        EmptyView()
                    }
                    ScrollView {
                        EmptyView()
                    }
                    VStack {
                        EmptyView()
                        EmptyView()
                    }
                    HStack {
                        EmptyView()
                        EmptyView()
                    }
                    ZStack {
                        EmptyView()
                        EmptyView()
                    }
                    Group {
                        EmptyView()
                        EmptyView()
                    }
                    VStack {
                        ForEach(0..<10) {
                            EmptyView()
                        }
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testStatement() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣HStack {
                    let value = 1
                    #if os(iOS)
                    EmptyView()
                    #endif
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'HStack' has only one child; consider using 'EmptyView' on its own")

    }
    
    func testAlignmentGuide1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    Child()
                    Child()
                        .alignmentGuide(1️⃣VerticalAlignment.center)
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'VerticalAlignment.center' doesn't match 'HorizontalAlignment.center' of 'VStack'")

    }
    
    func testAlignmentGuide2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    Child()
                    Child()
                        .alignmentGuide(1️⃣VerticalAlignment.top)
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'VerticalAlignment.top' doesn't match 'VerticalAlignment.center' of 'HStack'")

    }
    
    func testAlignmentGuide3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                ZStack(alignment: .topLeading) {
                    Child()
                    Child()
                        .alignmentGuide(1️⃣.bottom)
                        .alignmentGuide(2️⃣.trailing)
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)

        XCTAssertEqual(diagnostics("1️⃣"), "'VerticalAlignment.bottom' doesn't match 'VerticalAlignment.top' of 'ZStack'")
        XCTAssertEqual(diagnostics("2️⃣"), "'HorizontalAlignment.trailing' doesn't match 'HorizontalAlignment.leading' of 'ZStack'")

    }

}
