import XCTest
@testable import SwiftUILintExecutable

final class ViewBuilderCountDiagnoserTests: DiagnoserTestCase<ViewBuilderCountDiagnoser> {

    func testBodyWithNonGroupedViews() {

        let source = """
        struct ContentView: View {
            var body: some View 1️⃣{
                let _ = Self._printChanges()
                Image("")
                Text("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Use a container view to group 'Image' and 'Text'")

    }

    func testSomeViewPropertyWithNonGroupedViews() {

        let source = """
        struct ContentView: View {
            var body: some View {
                content
            }
            @ViewBuilder
            var content: some View 1️⃣{
                Image("")
                Text("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Use a container view to group 'Image' and 'Text'")

    }

    func testSomeViewFunctionWithNonGroupedViews() {

        let source = """
        struct ContentView: View {
            var body: some View {
                content
            }
            @ViewBuilder
            func content() -> some View 1️⃣{
                Image("")
                Text("")
            }
            func other() { }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Use a container view to group 'Image' and 'Text'")

    }

    func testSomeViewPropertyWithNonGroupedViews_NonTriggering1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    EmptyView()
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testSomeViewPropertyWithNonGroupedViews_NonTriggering2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                HStack {
                    EmptyView()
                    content
                }
            }
            @ViewBuilder
            var content: some View {
                Image("")
                Text("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

}
