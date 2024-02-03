import XCTest
import SwiftParser
import SwiftSyntax
@testable import PluginExecutable

final class SandboxTests: XCTestCase {

    func testCollect() async throws {

        let source = """
        struct ContentView: View {
            var body: some View {
                EmptyView()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .frame()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .padding()
                    .frame()
            }
        }
        """

        let elapsed1 = try ContinuousClock().measure {
            for _ in 0...100 {
                let _ = try source.matches(of: Regex(".frame"))
            }
        }

        print("elapsed time using regex: \(elapsed1)")

        let node = Parser.parse(source: source).child(StructDeclSyntax.self)!

        let elapsed2 = ContinuousClock().measure {
            for _ in 0...100 {
                let _ = ModifierCollector(modifier: "frame", node).matches
            }
        }

        print("elapsed time using collector: \(elapsed2)")

//
//        let properties = PropertyCollector(node).properties
//
//        XCTAssertEqual(properties.count, 3)

    }

}
