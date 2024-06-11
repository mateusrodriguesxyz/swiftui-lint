import XCTest
@testable import SwiftUILintExecutable

final class PropertyWrapperDiagnoserTests: DiagnoserTestCase<PropertyWrapperDiagnoser> {
    
    
    // MARK: Non Private State

    func testNonPrivateState() {

        let source = """
        struct ContentView: View {
            1️⃣@State var count = 0
            var body: some View {
                Button("Count") {
                    count += 1
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Variable 'count' should be declared as private to prevent unintentional memberwise initialization")
        
    }

    func testNonPrivateStateObject() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            1️⃣@StateObject var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Variable 'model' should be declared as private to prevent unintentional memberwise initialization")

    }
    
    // MARK: State Class Type

    func testStateClassType() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            1️⃣@State private var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(diagnostics("1️⃣"), "Mark 'Model' type with '@Observable' macro")

    }
    
    // MARK: Constant State

    func testConstantStateTriggering() {

        let source = """
        struct ContentView: View {
            
            1️⃣@State private var count: Int?
            
            var body: some View {
                EmptyView()
                    .onAppear {
                        if count == nil { }
                        if count != nil { }
                        let count = count ?? 0
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Variable 'count' was never mutated or used to create a binding; consider changing to 'let' constant")

    }
    
    func testConstantStateNonTriggering() {

        let source = """
        struct ContentView: View {
            
            @State private var count: Int?
            
            var body: some View {
                EmptyView()
                    .onAppear {
                        count = 1
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    func testConstantStateNonTriggeringExplicitSelf() {

        let source = """
        struct ContentView: View {
            
            @State private var count: Int?
            
            var body: some View {
                EmptyView()
                    .onAppear {
                        self.count = 1
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    // MARK: Binding Misused
    
    func testBindingInsteadOfBindable() {
        
        let source = """
        @Observable
        class Book: Identifiable {
            var title = "Sample Book Title"
            var isAvailable = true
        }

        struct BookView: View {
            
            @State private var book = Book()
            
            var body: some View {
                BookEditView(book: $book)
            }
            
        }


        struct BookEditView: View {
            
            1️⃣@Binding var book: Book
            
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Use 'Bindable' property wrapper instead")

        
    }
    
    // MARK: Unnecessary Binding
    
    func testUnnecessaryBinding1() {
        
        let source = """
        struct ContentView: View {
            
            1️⃣@Binding var value: Int
            
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Variable 'value' was never mutated or used as binding; consider changing to 'let' constant")

    }
    
    func testUnnecessaryBinding2() {
        
        let source = """
        struct ContentView: View {
            
            @State private var users: [User] = []

            var body: some View {
                List{
                    ForEach($users) { 1️⃣$user in
                        Text(user.name)
                    }
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Binding '$user' was never used")

    }
    
    // MARK: Unnecessary Bindable
    
    func testUnnecessaryBindable() {
        
        let source = """
        @Observable
        class Book: Identifiable {
            var title = "Sample Book Title"
            var isAvailable = true
        }

        struct BookEditView: View {
            
            1️⃣@Bindable var book: Book
            
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Property 'book' was never used to create a binding; consider removing 'Bindable' property wrapper")

    }
    
    // MARK: Initialized ObservedObject

    func testInitializedObservedObject() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            1️⃣@ObservedObject var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead")

    }

    func testInitializedObservedObjectWithSingleton() {

        let source = """
        class Model: ObservableObject {
            static var shared = Model()
        }

        struct ContentView: View {
            @ObservedObject var model = Model.shared
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    // MARK: Missing EnvironmentObject

    func testMissingEnvironmentObject1() {

        let source = """
        class Model: ObservableObject {
            static var shared = Model()
        }

        struct ParentView: View {
            @StateObject private var model = Model()
            var body: some View {
                ChildView()
            }
        }

        struct ChildView: View {
            1️⃣@EnvironmentObject var model: Model
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Insert object of type 'Model' in environment using 'environmentObject' modifier up in the hierarchy")

    }
    
    func testMissingEnvironmentObject2() {

        let source = """
        class Model: ObservableObject {
            static var shared = Model()
        }

        struct ParentView: View {
            @StateObject private var model = Model()
            var body: some View {
                VStack {
                    EmptyView()
                        .environmentObject(model)
                    ChildView()
                }
            }
        }

        struct ChildView: View {
            1️⃣@EnvironmentObject var model: Model
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Insert object of type 'Model' in environment using 'environmentObject' modifier up in the hierarchy")

    }
    
    func testMissingEnvironmentObject3() {
        
        let source = """
        @Observable
        class Model {
            
        }
        
        struct ContentView: View {
                
            @State private var model = Model()
            
            var body: some View {
                NavigationStack {
                    Child1()
                        .environment(model)
                }
            }
            
        }

        struct Child1: View {
        
            @Environment(Model.self) var model
                        
            var body: some View {
                NavigationLink("Child 2") {
                    Child2()
                }
            }
            
        }

        struct Child2: View {
            
            1️⃣@Environment(Model.self) var model
            
            var body: some View { }
            
        }
        """
        
        test(source)
        
        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Insert object of type 'Model' in environment using 'environment' modifier up in the hierarchy")
        
    }

    func testMissingEnvironmentObjectNonTriggering() {

        let source = """
        class Model: ObservableObject {
            static var shared = Model()
        }

        struct ParentView: View {
            @StateObject private var model = Model()
            var body: some View {
                ChildView()
                    .environmentObject(model)
            }
        }

        struct ChildView: View {
            @EnvironmentObject var model: Model
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    // MARK: Non-Triggering Properties

    func testNonTriggeringProperties() {

        let source = """

        @Observable
        class ObservableModel { }

        class ObservableObjectModel: ObservableObject {
            static var shared1 = ObservableObjectModel()
        }

        extension ObservableObjectModel {
            static var shared2 = ObservableObjectModel()
        }

        struct ParentView: View {

            @State 
            private private var bool1 = false

            @State
            private private var bool2 = false

            @State
            private private var bool3 = false

            @State 
            private var model1 = ObservableModel()

            @StateObject 
            private var model2 = ObservableObjectModel()

            @ObservedObject 
            var model3: ObservableObjectModel

            @ObservedObject 
            var model4 = ObservableObjectModel.shared1

            @ObservedObject
            var model5 = ObservableObjectModel.shared2

            var body: some View {
                Button("Set True") {
                    bool1 = true
                }
                Button("Toggle Method") {
                    bool2.toggle()
                }
                Toggle("Toggle Binding", isOn: $bool3)
            }

        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

}
