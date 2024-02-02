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

}
