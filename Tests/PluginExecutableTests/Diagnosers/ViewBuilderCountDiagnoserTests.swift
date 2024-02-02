import XCTest
@testable import PluginExecutable

final class ViewBuilderCountDiagnoserTests: DiagnoserTestCase<ViewBuilderCountDiagnoser> {

    func testBodyWithNonGroupedViews() throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                Child1()
                Child2()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use a container view to group 'Child1' and 'Child2'")

    }

    func testSomeViewPropertyWithNonGroupedViews() throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                content
            }
            @ViewBuilder
            var content: some View {
                Image("")
                Text("")
            }
        }
        """

        test(source)

        XCTExpectFailure("TODO")

        XCTAssertEqual(count, 1)

//        XCTAssertEqual(diagnostic.message, "Use a container view to group 'Image' and 'Text'")

    }

}
