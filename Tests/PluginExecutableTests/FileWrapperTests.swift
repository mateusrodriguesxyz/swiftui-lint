import XCTest
@testable import PluginExecutable

final class FileWrapperTests: XCTestCase {

    func testInit() throws {

        let path = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        let file = try XCTUnwrap(FileWrapper(path: path, cache: nil))

        XCTAssertEqual(file.name, "SwiftUIView")

    }

    func testModificationDate() throws {

        let path = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        let modificationDate = try Date("2022-05-26T18:06:55Z", strategy: .iso8601)

        try FileManager.default.setAttributes([.modificationDate : modificationDate], ofItemAtPath: path)

        let file = try XCTUnwrap(FileWrapper(path: path, cache: nil))

        XCTAssertEqual(file.modificationDate, modificationDate)

    }

}
