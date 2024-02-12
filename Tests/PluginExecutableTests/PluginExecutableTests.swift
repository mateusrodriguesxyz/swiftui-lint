import XCTest
@testable import PluginExecutable
import Foundation

final class PluginExecutableTests: XCTestCase {

    func testRunWithoutError() async throws {
        
        let directory = URL.temporaryDirectory.path()
        let file = Bundle.module.url(forResource: "SwiftUIView1", withExtension: nil)!.path()

        let command = try PluginExecutable.parseAsRoot([directory, file]) as! PluginExecutable

        try await command.run()

    }
    
    func testRunWithError() async throws {
        
        let directory = URL.temporaryDirectory.path()
        let file = Bundle.module.url(forResource: "SwiftUIView2", withExtension: nil)!.path()

        let command = try PluginExecutable.parseAsRoot([directory, file]) as! PluginExecutable

        do {
            try await command._run(cache: nil)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "exit 1")
        }

    }

}
