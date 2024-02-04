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

    func testHasChangesFalse() throws {

        let path = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        try FileManager.default.setAttributes([.modificationDate : Date.now.addingTimeInterval(-2000)], ofItemAtPath: path)

        let cache = Cache(modificationDates: [path : Date.now.addingTimeInterval(-1000)])

        let file = try XCTUnwrap(FileWrapper(path: path, cache: cache))

        XCTAssertEqual(file.hasChanges, false)

    }

    func testHasChangesTrue() throws {

        let path = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!.path()

        try FileManager.default.setAttributes([.modificationDate : Date.now], ofItemAtPath: path)

        let cache = Cache(modificationDates: [path : Date.now.addingTimeInterval(-1000)])

        let file = try XCTUnwrap(FileWrapper(path: path, cache: cache))

        XCTAssertEqual(file.hasChanges, true)

    }

}
