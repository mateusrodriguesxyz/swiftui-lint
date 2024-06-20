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
                .1️⃣navigationTitle()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Misplaced 'navigationTitle' modifier; apply it to 'NavigationStack' content instead")

    }

    func testMissingNavigationStack0() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .1️⃣navigationDestination() {
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
                1️⃣NavigationLink() {
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
                1️⃣NavigationLink("") {
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
                    1️⃣NavigationLink("") {
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
                1️⃣NavigationLink("") {
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
                            1️⃣NavigationLink("") {
                                EmptyView()
                            }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

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
                1️⃣NavigationLink("") {
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
                1️⃣NavigationLink("") {
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
                VStack {
                    NavigationLink("") {
                        EmptyView()
                    }
                    EmptyView()
                        .sheet(isPresented: .constant(true)) {
                            1️⃣NavigationLink("") {
                                EmptyView()
                            }
                        }
                        .popover(isPresented: .constant(true)) {
                            2️⃣NavigationLink("") {
                                EmptyView()
                            }
                        }
                        .fullScreenCover(isPresented: .constant(true)) {
                            3️⃣NavigationLink("") {
                                EmptyView()
                            }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)

        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("2️⃣"), "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("3️⃣"), "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")


    }
    
    func testMissingNavigationStack9() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                    NavigationLink("") {
                        
                    }
                    .navigationTitle("")
                    .sheet(isPresented: .constant(true)) {
                        1️⃣NavigationLink("") {
                            EmptyView()
                        }
                    }
                }
            }

        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; 'NavigationLink' only works within a navigation hierarchy")

    }
    
    func testMissingNavigationStack10() {

        let source = """
        struct ContentView: View {

            var body: some View {
                List {
                    Picker {
                        
                    }
                    .1️⃣pickerStyle(.navigationLink)
                }
            }

        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Missing 'NavigationStack'; '.navigationLink' only works within a navigation hierarchy")

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
    
    func testMissingNavigationStack_NonTrigerring7() {

        let source = """
        struct ContentView: View {

            var body: some View {
                NavigationStack {
                   link
                }
            }
        
            var link: some View {
                NavigationLink("NavigationLink") {
                    EmptyView()
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
                1️⃣NavigationStack {
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
                1️⃣NavigationLink("", destination: ContentView())
                2️⃣NavigationLink("", destination: { ContentView() })
                3️⃣NavigationLink("") {
                    ContentView()
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(diagnostics("1️⃣"), "To navigate back to 'ContentView' use environment 'DismissAction' instead")
        XCTAssertEqual(diagnostics("2️⃣"), "To navigate back to 'ContentView' use environment 'DismissAction' instead")
        XCTAssertEqual(diagnostics("3️⃣"), "To navigate back to 'ContentView' use environment 'DismissAction' instead")

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
                1️⃣NavigationLink("", destination: { ContentView() })
            }
        }
        """
        
        test(source)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "To go back more than one level in the navigation stack, use 'NavigationStack(path:root:)' initializer to access the navigation state")

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
                    .1️⃣navigationDestination(isPresented: .constant(true)) {
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
                1️⃣NavigationLink("Child 1") {
                    Child1()
                }
            }
            
        }
        """
        
        test(source)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "To navigate back to 'Child1' use environment 'DismissAction' instead")

        
        
    }

    func testMissingNavigationStackModifier1() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .1️⃣navigationTitle()
                    .2️⃣navigationBarTitleDisplayMode()
                    .toolbar {
                        3️⃣ToolbarItem { }
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'NavigationStack'; 'navigationTitle' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("2️⃣"), "Missing 'NavigationStack'; 'navigationBarTitleDisplayMode' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("3️⃣"), "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

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
                        1️⃣ToolbarItem { }
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
                                .1️⃣navigationTitle()
                                .2️⃣navigationBarTitleDisplayMode()
                                .toolbar {
                                    3️⃣ToolbarItem { }
                                }
                        }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'NavigationStack'; 'navigationTitle' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("2️⃣"), "Missing 'NavigationStack'; 'navigationBarTitleDisplayMode' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("3️⃣"), "Missing 'NavigationStack'; 'ToolbarItem' only works within a navigation hierarchy")

    }
    
    func testMissingNavigationStackModifier4() {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .1️⃣navigationTitle()
                    .2️⃣navigationBarTitleDisplayMode()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)
        XCTAssertEqual(diagnostics("1️⃣"), "Missing 'NavigationStack'; 'navigationTitle' only works within a navigation hierarchy")
        XCTAssertEqual(diagnostics("2️⃣"), "Missing 'NavigationStack'; 'navigationBarTitleDisplayMode' only works within a navigation hierarchy")

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
