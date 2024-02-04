import XCTest
@testable import PluginExecutable

final class ListDiagnoserTests: DiagnoserTestCase<ListDiagnoser> {

    func testMisplacedModifier() {

        let source = """
        struct ContentView: View {
            var body: some View {
                List {
                    EmptyView()
                }
                .listRowSeparator(.hidden)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Misplaced 'listRowSeparator' modifier; apply it to List rows instead")

    }

    func testSelectionTypeTriggering1() {

        let source = #"""
        struct ContentView2: View {

            @State private var selection: Int?

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                List(selection: $selection) {
                    ForEach(oceans, id: \.self) { ocean in
                        Text(ocean)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'ForEach' data element type 'String' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeTriggering2() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: Int?

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                List(oceans, id: \.self, selection: $selection) { ocean in
                    Text(ocean)
                }
            }
        }
        """#

        test(source)


        XCTExpectFailure()

        XCTAssertEqual(count, 1)

    }

    func testSelectionTypeTriggering3() {

        let source = #"""
        struct Ocean: Identifiable {
            let id = UUID()
            let name: String
        }

        struct ContentView: View {

            @State private var selection: Int?

            private var oceans = [
                Ocean(name: "Pacific"),
                Ocean(name: "Pacific"),
                Ocean(name: "Atlantic"),
                Ocean(name: "Indian"),
                Ocean(name: "Southern"),
                Ocean(name: "Arctic")
            ]

            var body: some View {
                List(selection: $selection) {
                    ForEach(oceans) { ocean in
                        Text(ocean.name)
                    }
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "'ForEach' data element 'Ocean' id type 'UUID' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeTriggering4() {

        let source = #"""
        struct Ocean: Identifiable {
            let id = UUID()
            let name: String
        }

        struct ContentView: View {

            @State private var selection: Int?

            private var oceans = [
                Ocean(name: "Pacific"),
                Ocean(name: "Pacific"),
                Ocean(name: "Atlantic"),
                Ocean(name: "Indian"),
                Ocean(name: "Southern"),
                Ocean(name: "Arctic")
            ]

            var body: some View {
                List(selection: $selection) {
                    ForEach(oceans, id: \.name) { ocean in
                        Text(ocean.name)
                    }
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "'ForEach' data element 'Ocean' member 'name' type 'String' doesn't match 'selection' type 'Int'")

    }

    func testPickerUnsupportedMultipleSelections() {

        let source = #"""
        struct ContentView: View {

            let colors = ["Red", "Green", "Blue"]

            @State private var selection = Set<String>()

            var body: some View {
                Picker("Color", selection: $selection) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "'Picker' doesn't support multiple selections")

    }

    func testPickerMissingTag() {

        let source = #"""
        struct ContentView: View {

            @State private var selection = 0

            var body: some View {
                Picker("Color", selection: $selection) {
                    Text("Red")
                        .tag(0)
                    Text("Green")
                        .tag(1)
                    Text("Blue")
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "Apply 'tag' modifier with 'Int' value to match 'selection' type")

    }

    func testPickerWrongTagType() {

        let source = #"""
        struct ContentView: View {

            @State private var selection = 0

            var body: some View {
                Picker("Color", selection: $selection) {
                    Text("Red")
                        .tag(0)
                    Text("Green")
                        .tag(1)
                    Text("Blue")
                        .tag("blue")
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostic.message, "tag value 'blue' type 'String' doesn't match 'selection' type 'Int'")

    }

}
