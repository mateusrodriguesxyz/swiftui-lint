import XCTest
@testable import PluginExecutable

final class PropertyWrapperDiagnoserTests: DiagnoserTestCase<PropertyWrapperDiagnoser> {
    
    
    // MARK: Non Private State

    func testNonPrivateState() {

        let source = """
        struct ContentView: View {
            @State var count = 0
            var body: some View {
                Button("Count") {
                    count += 1
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Variable 'count' should be declared as private to prevent unintentional memberwise initialization")
        
    }

    func testNonPrivateStateObject() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            @StateObject var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Variable 'model' should be declared as private to prevent unintentional memberwise initialization")

    }
    
    // MARK: State Class Type

    func testStateClassType() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            @State private var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(diagnostic.message, "Mark 'Model' type with '@Observable' macro or, alternatively, use 'StateObject' property wrapper instead")

    }
    
    // MARK: Constant State

    func testConstantStateTriggering() {

        let source = """
        struct ContentView: View {
            
            @State private var count: Int?
            
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

        XCTAssertEqual(diagnostic.message, "Variable 'count' was never mutated or used to create a binding; consider changing to 'let' constant")

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
    
    // MARK: Binding Misused
    
    func testBindingMisused() {
        
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
            
            @Binding var book: Book
            
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Use 'Bindable' property wrapper instead")

        
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
            
            @Bindable var book: Book
            
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Property 'book' was never used to create a binding; consider removing 'Bindable' property wrapper")

        
    }
    
    // MARK: Initialized ObservedObject

    func testInitializedObservedObject() {

        let source = """
        class Model: ObservableObject { }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead")

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
            @EnvironmentObject var model: Model
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Insert object of type 'Model' in environment with 'environmentObject' up in the hierarchy")

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
            @EnvironmentObject var model: Model
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Insert object of type 'Model' in environment with 'environmentObject' up in the hierarchy")

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
