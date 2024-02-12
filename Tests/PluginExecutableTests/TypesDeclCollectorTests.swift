import XCTest
import SwiftParser
import SwiftSyntax
@testable import PluginExecutable

final class TypesDeclCollectorTests: XCTestCase {

    func test() {

        let source = """
        struct T1 { }
        enum T2 { }
        class T3 { }
        actor T4 { }
        extension T1 { }
        """

        let file = FileWrapper(source)

        let collector = TypesDeclCollector(file)

        XCTAssertEqual(collector.all.count, 4)

        XCTAssertEqual(collector.structs.count, 1)
        XCTAssertEqual(collector.structs.first!.name.trimmedDescription, "T1")

        XCTAssertEqual(collector.enums.count, 1)
        XCTAssertEqual(collector.enums.first!.name.trimmedDescription, "T2")

        XCTAssertEqual(collector.classes.count, 1)
        XCTAssertEqual(collector.classes.first!.name.trimmedDescription, "T3")

        XCTAssertEqual(collector.actors.count, 1)
        XCTAssertEqual(collector.actors.first!.name.trimmedDescription, "T4")

        XCTAssertEqual(collector.extensions.count, 1)
        XCTAssertEqual(collector.extensions.first!.extendedType.trimmedDescription, "T1")

    }
    
    func test2() {

        let source = """
        struct Model {
            let a = 1
            let b = 2
            let c = 3
        }
        extension Model {
            static let d = 4
            static let e = 5
        }
        """

        let content = Context(source)

        let model = content.types.structs.first!

        XCTAssertEqual(model.properties(nil).count, 3)
        XCTAssertEqual(model.properties(content).count, 5)

    }

    func test3() {

        let file = Bundle.module.url(forResource: "SwiftUIView", withExtension: nil)!

        let context = Context(files: [file.path()])

        XCTAssertEqual(context.types.structs.count, 1)

    }


}
