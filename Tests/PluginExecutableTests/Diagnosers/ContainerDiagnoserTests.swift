import XCTest
@testable import PluginExecutable

final class ContainerDiagnoserTests: DiagnoserTestCase<ContainerDiagnoser> {

    func testEmptyVStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {

                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'VStack' has no children; consider removing it")

    }

    func testVStackWithOnlyChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'VStack' has only one child; consider using 'EmptyView' on its own")

    }

    func testNavigationStackWithMoreThanOneChild() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    Color.red
                    Color.green
                    Color.blue
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use a container view to group 'Color', 'Color' and 'Color'")

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
                HStack {
                    #if os(iOS)
                    EmptyView()
                    #endif
                }
            }
        }
        """

        test(source)

        XCTExpectFailure()

        XCTAssertEqual(count, 1)

    }

}
