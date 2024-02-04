import XCTest
@testable import PluginExecutable

final class NavigationDiagnoserTests: DiagnoserTestCase<NavigationDiagnoser> {

    func testMisplacedModifier() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                }
                .navigationTitle("")
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Misplaced 'navigationTitle' modifier; apply it to NavigationStack content instead")

    }

    func testMissingNavigationStack0() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .navigationDestination(isPresented: .constant(true)) {
                        EmptyView()
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'navigationDestination' only works within a navigation hierarchy")

    }

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
                    NavigationLink("") {
                        EmptyView()
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'NavigationLink' only works within a navigation hierarchy")

    }

    func testMissingNavigationStack4() {

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

    func testMissingNavigationStack5() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            NavigationLink("") {
                                EmptyView()
                            }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

    }

    func testMissingNavigationStack6() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            SheetContent()
                        }
                }
            }

        }

        struct SheetContent: View {
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

    func testMissingNavigationStack7() {

        let source = """
        struct ContentView: View {

            var body: some View {
                TabView {
                    NavigationStack {
                        ChildView1()
                    }
                    NavigationStack {
                        ChildView2()
                    }
                    ChildView3()
                }
            }

        }

        struct ChildView1: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }

        struct ChildView2: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }

        struct ChildView3: View {
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

    func testMissingNavigationStack8() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                    ChildView()
                }
            }

        }

        struct ChildView: View {
            var body: some View {
                EmptyView()
                    .sheet(isPresented: .constant(true)) {
                        NavigationLink("") {
                            EmptyView()
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'NavigationLink' only works within a navigation hierarchy")

    }

    func testMissingNavigationStack_NonTrigerring1() {

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

    func testMissingNavigationStack_NonTrigerring2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    ChildView()
                }
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

        XCTAssertEqual(count, 0)

    }

    func testMissingNavigationStack_NonTrigerring3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationSplitView {
                    NavigationLink("") {
                        EmptyView()
                    }
                } detail: {

                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testMissingNavigationStack_NonTrigerring4() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationSplitView {
                    SidebarView()
                } detail: {

                }
            }
        }

        struct SidebarView: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
                }
            }
        }

        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testMissingNavigationStack_NonTrigerring5() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            NavigationStack {
                                NavigationLink("") {
                                    EmptyView()
                                }
                            }
                        }
                }
            }

        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testMissingNavigationStack_NonTrigerring6() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            NavigationStack {
                                SheetContent()
                            }
                        }
                }
            }

        }

        struct SheetContent: View {
            var body: some View {
                NavigationLink("") {
                    EmptyView()
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
    
    func testExtraNavigationStack() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    ChildView()
                }
            }
        }

        struct ChildView: View {
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

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "'ChildView' should not contain a NavigationStack")

    }

    func testNavigationLoop1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    ChildView()
                }
            }
        }

        struct ChildView: View {
            var body: some View {
                NavigationLink("") {
                    ContentView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "To navigate back to 'ContentView' use environment 'DismissAction' instead")

    }

    func testNavigationLoop2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    ChildView1()
                }
            }
        }

        struct ChildView1: View {
            var body: some View {
                NavigationLink("") {
                    ChildView2()
                }
            }
        }

        struct ChildView2: View {
            var body: some View {
                NavigationLink("") {
                    ContentView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "To go back more than one level in the navigation stack, use NavigationStack 'init(path:root:)' to store the navigation state as a 'NavigationPath', pass it down the hierarchy and call 'removeLast(_:)'")

    }

    func testNavigationLoop3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    ChildView()
                }
            }
        }

        struct ChildView: View {
            var body: some View {
                EmptyView()
                    .navigationDestination(isPresented: .constant(true)) {
                        ContentView()
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "To navigate back to 'ContentView' use environment 'DismissAction' instead")

    }

    func testMissingNavigationStackModifier1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar { }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'toolbar' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackModifier2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .toolbar { }
                }
                EmptyView()
                    .toolbar { }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'toolbar' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackModifier3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            EmptyView()
                                .toolbar { }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Missing NavigationStack; 'toolbar' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackModifierNonTriggering1() {

        let source = """
                struct ContentView: View {
                    var body: some View {
                        NavigationStack {
                            EmptyView()
                                .toolbar { }
                        }
                    }
                }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testMissingNavigationStackModifierNonTriggering2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            NavigationStack {
                                EmptyView()
                                    .toolbar { }
                            }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

}
