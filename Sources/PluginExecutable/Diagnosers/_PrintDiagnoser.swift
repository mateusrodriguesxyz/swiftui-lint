//import SwiftSyntax
//import Foundation
//
//struct Formatted: Codable {
//
//    struct Location: Codable {
//
//        let file: String
//        let line: Int
//        let column: Int
//
//        init(_ location: SourceLocation) {
//            self.file = location.file
//            self.line = location.line
//            self.column = location.column
//        }
//
//    }
//
//    struct Parameter: Codable {
//        let label: String?
//        let value: String
//        let type: TypeWrapper?
//    }
//
//    struct Modifier: Codable {
//
//        let name: String
//        let parameters: [Parameter]
//        let location: Location
//    }
//
//    struct Child: Codable {
//
//        let name: String
//        let modifiers: [Modifier]
//        let child: [Child]?
//
//        init(_ child: ViewChildWrapper, file: FileWrapper) {
//            self.name = child.name
//            self.modifiers = AllModifiersCollector(child.node).matches.map {
//                let name = $0.decl.baseName.text
//                let parameters = $0.arguments.map {
//                    Parameter(label: $0.label?.text, value: $0.expression.trimmedDescription, type: .init($0.expression))
//                }
//                let location = Location(file.location(of: $0.decl))
//                return Modifier(name: name, parameters: parameters, location: location)
//            }
//            if let children = StackDeclWrapper(child.node)?.children {
//                self.child = children.map { Child($0, file: file) }
//            } else {
//                self.child = nil
//            }
//        }
//
//    }
//
//    struct Property: Codable {
//
//        let location: Location
//        let name: String
//        let attributes: Set<String>
//        let keywords: Set<String>
//        let hasInitializer: Bool
//        let type: TypeWrapper?
//
//        init(_ property: PropertyDeclWrapper, file: FileWrapper) {
//            let node = property.node.as(VariableDeclSyntax.self)!
//            self.location = Location(file.location(of: node))
//            self.name = property.name
//            self.attributes = property.attributes
//            self.keywords = Set(node.modifiers.map(\.name.text) + [node.bindingSpecifier.text])
//            self.hasInitializer = property.hasInitializer
//            self.type = property._type
//        }
//
//    }
//
//    struct View: Codable {
//        let name: String
//        let properties: [Property]
//        let children: [Child]
//    }
//
//}
//
//extension ViewDeclWrapper {
//
//    func formatted() -> Formatted.View {
//        Formatted.View(
//            name: name,
//            properties: properties.map { Formatted.Property($0, file: file) },
//            children: body?.elements.map { Formatted.Child($0, file: file) } ?? []
//        )
//    }
//
//}
//
//struct _PrintDiagnoser: Diagnoser {
//
//    func diagnose(_ view: ViewDeclWrapper) {
//        fatalError()
//    }
//
//    func run(context: Context) {
//
//        let encoder = JSONEncoder()
//
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
//
//        for view in context.views {
//            print(String(data: try! encoder.encode(view.formatted()), encoding: .utf8)!)
//
//        }
//
//    }
//
//}
