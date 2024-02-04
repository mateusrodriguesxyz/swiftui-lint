import XCTest
@testable import PluginExecutable

final class PluginExecutableTests: XCTestCase {

    func testRun() async throws {

        let directory = URL.temporaryDirectory.path()
        let file = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        let command = try PluginExecutable.parseAsRoot([directory, file]) as! PluginExecutable

        do {
            try await command.run()
        } catch {
            XCTAssertEqual(error.localizedDescription, "exit 1")
        }

    }

}
