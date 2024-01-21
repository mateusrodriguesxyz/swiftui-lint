import XCTest
@testable import SwiftUILintExecutable


final class TypeWrapperTests: XCTestCase {

    func testDescription() {
        XCTAssertEqual(TypeWrapper.plain("Int").description, "Int")
        XCTAssertEqual(TypeWrapper.optional(.plain("Int")).description, "Int?")
        XCTAssertEqual(TypeWrapper.array(.plain("Int")).description, "[Int]")
        XCTAssertEqual(TypeWrapper.set(.plain("Int")).description, "Set<Int>")
        XCTAssertEqual(TypeWrapper.dictionary(.plain("Int"), .array(.plain("String"))).description, "[Int : [String]]")
        XCTAssertEqual(TypeWrapper.optional(.array(.plain("Int"))).description, "[Int]?")
    }

    func testBaseType() {
        XCTAssertEqual(TypeWrapper.plain("Int").baseType, "Int")
        XCTAssertEqual(TypeWrapper.optional(.plain("Int")).baseType, "Int")
        XCTAssertEqual(TypeWrapper.array(.plain("Int")).baseType, "Int")
        XCTAssertEqual(TypeWrapper.set(.plain("Int")).baseType, "Int")
        XCTAssertEqual(TypeWrapper.dictionary(.plain("Int"), .array(.plain("String"))).baseType, "(Int,[String])")
    }

    func testIsSet() {
        XCTAssertEqual(TypeWrapper.plain("Int").isSet, false)
        XCTAssertEqual(TypeWrapper.optional(.plain("Int")).isSet, false)
        XCTAssertEqual(TypeWrapper.array(.plain("Int")).isSet, false)
        XCTAssertEqual(TypeWrapper.set(.plain("Int")).isSet, true)
    }

    func testStringInterpolation() {
        XCTAssertEqual("\(TypeWrapper.optional(.array(.plain("Int"))))", "optional(array(plain(Int)))")

    }

    func testViewProperties() async {

        let source = #"""

        struct Ocean: Identifiable {
            let id = UUID()
            let name: String
        }
        
        enum E {
            case a, b, c
        }

        struct S {
            static var a = S()
            static var b = S()
            static var c = S()
            static var all = [a, b, c]
        }

        struct A { 
            static var b = B()
        }

        struct B {
            static var c = C()
        }

        struct C {
            static var d = 5
        }

        struct ContentView: View {

            let int1: Int
            let int2 = 1

            let double1: Double
            let double2 = 1.5

            let bool1: Bool
            let bool2 = true

            let string1: String
            let string2 = ""

            let array1: [Int]
            let array2: Array<Int>
            let array3 = [1, 2, 3]

            let set1: Set<Int>
            let set2 = Set<Int>()

            let dict1: [Int: [String]]

            let optional1: Int?
            let optional2: Optional<Int>
            let optional3: [Int]?
            let optional4 = Optional(1)
            let optional5 = 1 as Int?

            var ref1 = E.a
            var ref2 = S.a
            var ref3 = [S.a]
            var ref4 = S.all
            var ref5 = A.b.c.d

            lazy var ref6 = int1

            @Environment(\.dismiss) private var env

            let today = Calendar.current.startOfDay(for: .now)
        
            @State var selection = Set<Ocean.ID>()

            var body: some View {
                EmptyView()
            }
        }
        """#

        let context = await Context(source)

        let content = context.views.first!

        XCTAssertEqual(content.property(named: "int1")?._type, .plain("Int"))
        XCTAssertEqual(content.property(named: "int2")?._type, .plain("Int"))

        XCTAssertEqual(content.property(named: "double1")?._type, .plain("Double"))
        XCTAssertEqual(content.property(named: "double2")?._type, .plain("Double"))

        XCTAssertEqual(content.property(named: "bool1")?._type, .plain("Bool"))
        XCTAssertEqual(content.property(named: "bool2")?._type, .plain("Bool"))

        XCTAssertEqual(content.property(named: "string1")?._type, .plain("String"))
        XCTAssertEqual(content.property(named: "string2")?._type, .plain("String"))

        XCTAssertEqual(content.property(named: "array1")?._type, .array(.plain("Int")))
        XCTAssertEqual(content.property(named: "array2")?._type, .array(.plain("Int")))
        XCTAssertEqual(content.property(named: "array3")?._type, .array(.plain("Int")))

        XCTAssertEqual(content.property(named: "set1")?._type, .set(.plain("Int")))
        XCTAssertEqual(content.property(named: "set2")?._type, .set(.plain("Int")))

        XCTAssertEqual(content.property(named: "dict1")?._type, .dictionary(.plain("Int"), .array(.plain("String"))))

        XCTAssertEqual(content.property(named: "optional1")?._type, .optional(.plain("Int")))
        XCTAssertEqual(content.property(named: "optional2")?._type, .optional(.plain("Int")))
        XCTAssertEqual(content.property(named: "optional3")?._type, .optional(.array(.plain("Int"))))
        XCTAssertEqual(content.property(named: "optional4")?._type, .optional(.plain("Int")))
        XCTAssertEqual(content.property(named: "optional5")?._type, .optional(.plain("Int")))

        XCTAssertEqual(content.property(named: "ref1")?._type(context), .plain("E"))
        XCTAssertEqual(content.property(named: "ref2")?._type(context), .plain("S"))
        XCTAssertEqual(content.property(named: "ref3")?._type(context), .array(.plain("S")))
        XCTAssertEqual(content.property(named: "ref4")?._type(context), .array(.plain("S")))
        XCTAssertEqual(content.property(named: "ref5")?._type(context), .plain("Int"))
        XCTAssertEqual(content.property(named: "ref6")?._type(context, baseType: content.node), .plain("Int"))

        XCTAssertEqual(content.property(named: "env")?._type(context), .plain("DismissAction"))

        XCTAssertNil(content.property(named: "today")?._type(context, baseType: content.node))
        
//        XCTAssertEqual(content.property(named: "selection")?._type(context), .plain("DismissAction"))

    }


}
