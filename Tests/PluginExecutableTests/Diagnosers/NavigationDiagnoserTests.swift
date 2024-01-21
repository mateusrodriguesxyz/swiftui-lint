import XCTest
@testable import SwiftUILintExecutable

final class NavigationDiagnoserTests: DiagnoserTestCase<NavigationDiagnoser> {

    func testMisplacedModifier() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                }
                .navigationTitle()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Misplaced 'navigationTitle' modifier; apply it to 'NavigationStack' content instead")

    }

    func testMissingNavigationStack0() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .navigationDestination() {
                        EmptyView()
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'navigationDestination' only works within a navigation hierarchy")

    }

    func testMissingNavigationStack1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationLink() {
                    EmptyView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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
                    .popover(isPresented: .constant(true)) {
                        NavigationLink("") {
                            EmptyView()
                        }
                    }
                    .fullScreenCover(isPresented: .constant(true)) {
                        NavigationLink("") {
                            EmptyView()
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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

        iOSDeploymentVersion = 16.0

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

        iOSDeploymentVersion = 15.0

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
    
    func testExtraNavigationStackTriggering() {

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
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            NavigationStack {
                                EmptyView()
                            }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "'ChildView' should not contain a NavigationStack")

    }
    
    func testExtraNavigationStackNonTriggering() {

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
                        NavigationStack {
                            EmptyView()
                        }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

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
                NavigationLink("", destination: ContentView())
                NavigationLink("", destination: { ContentView() })
                NavigationLink("") {
                    ContentView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
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
                NavigationLink("", destination: { ContentView() })
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
    
    func testNavigationLoop4() {
        
        let source = """
        struct ContentView: View {
                            
            var body: some View {
                NavigationStack {
                    Child1()
                }
            }
            
        }

        struct Child1: View {
                        
            var body: some View {
                NavigationLink("Child2") {
                    Child2()
                }
            }
            
        }

        struct Child2: View {
        
            var body: some View {
                NavigationLink("Child 1") {
                    Child1()
                }
            }
            
        }
        """
        
        test(source)
        
        XCTAssertEqual(count, 1)
        
        
    }

    func testMissingNavigationStackModifier1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .navigationTitle()
                    .navigationBarTitleDisplayMode()
                    .toolbar {
                        ToolbarItem { }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(diagnoser.diagnostics[0].message, "Missing 'NavigationStack'; 'navigationTitle' only works within a navigation hierarchy")
//        XCTAssertEqual(diagnoser.diagnostics[1].message, "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackModifier2() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .toolbar {
                            
                        }
                }
                EmptyView()
                    .toolbar {
                        ToolbarItem { }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

    }

    func testMissingNavigationStackModifier3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            EmptyView()
                                .navigationTitle()
                                .navigationBarTitleDisplayMode()
                                .toolbar {
                                    ToolbarItem { }
                                }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(diagnoser.diagnostics[0].message, "Missing 'NavigationStack'; 'navigationTitle' only works within a navigation hierarchy")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Missing 'NavigationStack'; 'navigationBarTitleDisplayMode' only works within a navigation hierarchy")
        XCTAssertEqual(diagnoser.diagnostics[2].message, "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

    }
    
    func testMissingNavigationStackModifier4() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .navigationTitle()
                    .navigationBarTitleDisplayMode()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)
//        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

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
    
    func testMissingNavigationStackModifierNonTriggering3() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        ToolbarItem(.keyboard) { }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    func testMissingNavigationStackModifierNonTriggering4() {
        
        macOSDeploymentVersion = 13

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .toolbar {
                        ToolbarItem { }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    func testDestination() {
        
        let source = """
        struct ContentView: View {
            var body: some View {
                NavigationStack {
                    NavigationLink("A") {
                        A()
                    }
                    NavigationLink("B") {
                        B()
                    }
                }
            }
        }
        
        
        struct A: View {
            var body: some View {
                NavigationLink("X") {
                    X()
                }
            }
        }
        
        struct B: View {
            var body: some View {
                NavigationLink("X") {
                    X()
                }
            }
        }
        
        """
        

        test(source)
        
        XCTAssertEqual(count, 0)
        
        

    }

}
