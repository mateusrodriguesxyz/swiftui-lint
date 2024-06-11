import XCTest
@testable import SwiftUILintExecutable

final class ListDiagnoserTests: DiagnoserTestCase<ListDiagnoser> {

    func testMisplacedModifier() {

        let source = """
        struct ContentView: View {
            var body: some View {
                List {
                    EmptyView()
                }
                .1️⃣listRowSeparator(.hidden)
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "Misplaced 'listRowSeparator' modifier; apply it to List rows instead")

    }

    func testSelectionTypeTriggering1() {

        let source = #"""
        struct ContentView2: View {

            @State private var selection: Int?

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                List(selection: $selection) {
                    1️⃣ForEach(oceans, id: \.self) { ocean in
                        Text(ocean)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element type 'String' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeTriggering2() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: Int?

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                1️⃣List(oceans, id: \.self, selection: $selection) { ocean in
                    Text(ocean)
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element type 'String' doesn't match 'selection' type 'Int'")

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
                    1️⃣ForEach(oceans) { ocean in
                        Text(ocean.name)
                    }
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element 'Ocean' id type 'UUID' doesn't match 'selection' type 'Int'")

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
                    1️⃣ForEach(oceans, id: \.name) { ocean in
                        Text(ocean.name)
                    }
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element 'Ocean' member 'name' type 'String' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeTriggering5() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: Int?

            var body: some View {
                1️⃣List(["Pacific", "Atlantic", "Indian", "Southern", "Arctic"], id: \.self, selection: $selection) { ocean in
                    Text(ocean)
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element type 'String' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeTriggering6() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: String?

            var body: some View {
                List(selection: $selection) {
                    1️⃣ForEach(0..<5) { index in
                        Text("\(index)")
                    }
                }
            }
        }
        """#

        test(source)


        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element type 'Int' doesn't match 'selection' type 'String'")

    }

    func testPickerUnsupportedMultipleSelections() {

        let source = #"""
        struct ContentView: View {

            let colors = ["Red", "Green", "Blue"]

            @State private var selection = Set<String>()

            var body: some View {
                Picker("Color", selection: 1️⃣$selection) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'Picker' doesn't support multiple selections")

    }

    func testPickerMissingTag1() {

        let source = #"""
        struct ContentView: View {

            @State private var selection = 0

            var body: some View {
                Picker("Color", selection: $selection) {
                    Text("Red")
                        .tag(0)
                    Text("Green")
                        .tag(1)
                    1️⃣Text("Blue")
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Apply 'tag' modifier with 'Int' value to match 'selection' type")

    }
    
    func testPickerMissingTag2() {

        let source = #"""
        struct ContentView: View {

            @State private var selection = 0

            var body: some View {
                List {
                    Picker("Color", selection: $selection) {
                        Text("Red")
                            .tag(0)
                        Text("Green")
                            .tag(1)
                        1️⃣Text("Blue")
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Apply 'tag' modifier with 'Int' value to match 'selection' type")

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
                        .tag(1️⃣"blue")
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "tag value 'blue' type 'String' doesn't match 'selection' type 'Int'")

    }

    func testSelectionTypeNonTriggering() {

        let source = #"""
        struct SomeType {
            static var stringValue = ""
        }

        struct ContentView: View {

            @State private var selection = SomeType.stringValue

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                List(oceans, id: \.self, selection: $selection) { ocean in
                    Text(ocean)
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 0)

    }

    func testSelectionTypeNonTriggering2() {

        let source = #"""
        struct ContentView: View {

            @State private var selection = SomeType.stringValue

            private var oceans = ["Pacific", "Atlantic", "Indian", "Southern", "Arctic"]

            var body: some View {
                List(oceans, id: \.self, selection: $selection) { ocean in
                    Text(ocean)
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 0)

    }
    
    func testSelectionTypeNonTriggering3() {

        let source = #"""
        struct Ocean: Identifiable {
            let id = UUID()
            let name: String
        }

        struct ContentView: View {

            @State private var selection: Ocean.ID?

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

        XCTAssertEqual(count, 0)

    }

    func testSelectionTypeTriggering7() {

        let source = #"""
        enum Flavor: String, CaseIterable, Identifiable {
            case chocolate, vanilla, strawberry
            var id: Self { self }
        }

        struct ContentView: View {

            @State private var selection = ""

            var body: some View {
                Picker("Flavor", selection: $selection) {
                    Text("Chocolate").tag(Flavor.chocolate)
                    Text("Vanilla").tag(Flavor.vanilla)
                    Text("Strawberry").tag(Flavor.strawberry)
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 3)

    }
    
    func testSelectionTypeTriggering8() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: Int?

            private var oceans = [
                "Pacific",
                "Pacific",
                "Atlantic",
                "Indian",
                "Southern",
                "Arctic"
            ]

            var body: some View {
                Picker("Ocean", selection: $selection) {
                    1️⃣ForEach(oceans, id: \.self) { ocean in
                        Text(ocean)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' data element type 'String' doesn't match 'selection' type 'Int?'")

    }
    
    #warning("FIX DIAGNOSTIC LOCATION")
    func testSelectionTypeTriggering9() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: String?

            private var oceans = [
                "Pacific",
                "Pacific",
                "Atlantic",
                "Indian",
                "Southern",
                "Arctic"
            ]

            var body: some View {
                Picker("Ocean", selection: $selection) {
                    ForEach(oceans, id: \.self) { ocean in
                        Text(ocean1️⃣)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "Apply 'tag' modifier with explicit Optional<String> value to match 'selection' type 'String?'")

    }
    
    func testSelectionTypeTriggering10() {

        let source = #"""
        struct ContentView: View {

            @State private var selection: String?

            private var oceans = [
                "Pacific",
                "Pacific",
                "Atlantic",
                "Indian",
                "Southern",
                "Arctic"
            ]

            var body: some View {
                Picker("Ocean", selection: $selection) {
                    ForEach(oceans, id: \.self) { ocean in
                        Text(ocean)
                            .tag(1️⃣5)
                    }
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "tag value '5' type 'Int' doesn't match 'selection' type 'String?'")

    }
    
    func testSelectionTypeNonTriggering10() {

        let source = #"""
        struct Ocean: Identifiable {
            let id = UUID()
            let name: String
        }

        struct ContentView: View {

            @State private var selection = Set<Ocean.ID>()

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

        XCTAssertEqual(count, 0)

    }
    
    func testClosedRange() {
        
        let source = #"""
        struct ContentView: View {

            var body: some View {
                ForEach(1️⃣1...5) {
                    Text("Row \($0)")
                }
            }
        }
        """#

        test(source)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(diagnostics("1️⃣"), "'ForEach' doesn't support closed range; use an open range instead (1..<5)")

    }

}
