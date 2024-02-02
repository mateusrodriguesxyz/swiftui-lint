import XCTest
@testable import PluginExecutable

final class NavigationDiagnoserTests: DiagnoserTestCase<NavigationDiagnoser> {

    func testMissingNavigationStack1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'NavigationLink' only works within a navigation hierarchy")

    }

    func testMissingNavigationStack2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                ChildView()
            }
        }

        struct ChildView: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'NavigationLink' only works within a navigation hierarchy")

    }

    func testMissingNavigationStack3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationSplitView {

                } detail: {
                    DetailView()
                }
            }
        }

        struct DetailView: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }

        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'NavigationLink' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackNonTriggering1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    NavigationLink("") {
                        EmptyView()
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testDeprecatedNavigationViewTriggering() {

        minimumDeploymentVersion = 16.0

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationView {
                    NavigationLink("") {
                        EmptyView()
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'NavigationView' is deprecated; use NavigationStack or NavigationSplitView instead")

    }

    func testDeprecatedNavigationViewNonTriggering() {

        minimumDeploymentVersion = 15.0

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationView {
                    NavigationLink("") {
                        EmptyView()
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

}
