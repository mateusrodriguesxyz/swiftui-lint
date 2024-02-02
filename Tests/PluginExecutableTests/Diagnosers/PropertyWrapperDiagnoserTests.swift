import XCTest
@testable import PluginExecutable

final class PropertyWrapperDiagnoserTests: DiagnoserTestCase<PropertyWrapperDiagnoser> {

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

    func testConstantState() {

        let source = """
        struct ContentView: View {
            @State private var count = 0
            var body: some View {
                EmptyView()
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Variable 'count' was never mutated or used to create a binding; consider changing to 'let' constant")

    }

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

    func testMissingEnvironmentObject() {

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

    func testNonMissingEnvironmentObject() {

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
            private private var count = 5

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
                Button("Count") {
                    count += 1
                }
            }

        }
        """

        test(source)

        XCTAssertEqual(count, 0)

    }

}
