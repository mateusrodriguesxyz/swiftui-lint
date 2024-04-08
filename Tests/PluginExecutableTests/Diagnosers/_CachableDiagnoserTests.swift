import XCTest
@testable import PluginExecutable

final class CachableDiagnoserTests: XCTestCase {

    func testCache() async throws {

        let diagnoser = ContainerDiagnoser()

        let path = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        try FileManager.default.setAttributes([.modificationDate : Date.now.addingTimeInterval(-2000)], ofItemAtPath: path)

        let diagnostic = Diagnostic(origin: "ContainerDiagnoser", kind: .warning, location: .init(line: 0, column: 0, offset: 0, file: path), offset: 0, message: "⭐️")

        let cache = Cache(modificationDates: [:], diagnostics: ["ContainerDiagnoser" : [diagnostic]])


        let file = try XCTUnwrap(FileWrapper(path: path, hasChanges: false))

        let context = await Context(file)
        
        context.cache = cache


        diagnoser.run(context: context)

        XCTAssertEqual(diagnoser.diagnostics.count, 1)
        XCTAssertEqual(diagnoser.diagnostics.first?.message, "⭐️")
        
    }

}
