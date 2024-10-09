import XCTest
@testable import SwiftUILintExecutable

final class RepeatedModifierDiagnoserTests: DiagnoserTestCase<RepeatedModifierDiagnoser> {

    func testRepeatedModiferAllChildren() {

        let source = """
        struct ContentView: View {
            var body: some View {
                1️⃣VStack {
                    Text("")
                        .foregroundStyle(.red)
                    Text("")
                        .foregroundStyle(.red)
                    Text("")
                        .foregroundStyle(.red)
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(diagnostics("1️⃣"), "'foregroundStyle(.red)' repeated in all children; consider applying it to 'VStack' instead")

    }
    
    func testRepeatedModiferSiblings() {

        let source = """
        struct ContentView: View {
            var body: some View {
                VStack {
                    Text("")
                        .foregroundStyle(.green)
                    Text("")
                        .1️⃣foregroundStyle(.red)
                    Text("")
                        .2️⃣foregroundStyle(.red)
                }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 2)
        
        XCTAssertEqual(diagnostics("1️⃣"), "'foregroundStyle(.red)' modifier repeated in sibling (line 8); consider collecting them using 'Group' and applying modifier to the 'Group' instead")
        XCTAssertEqual(diagnostics("2️⃣"), "'foregroundStyle(.red)' modifier repeated in sibling (line 6); consider collecting them using 'Group' and applying modifier to the 'Group' instead")


    }
    
}
