import SwiftSyntax

struct SwiftFileDeclaration: Codable {

    let name: String
    let path: String?
    let types: [SwiftTypeDeclaration]

}

extension FileWrapper {

    func codable(_ context: Context) -> SwiftFileDeclaration {

        func _properties(of node: SyntaxProtocol) -> [SwiftPropertyDeclaration] {
            return node.properties(context).map({ SwiftPropertyDeclaration($0, file: self, baseType: node, context: context) })
        }

        func _cases(of node: SyntaxProtocol) -> [String] {
            if let node = node.as(EnumDeclSyntax.self) {
                return CaseCollector(node).matches
            } else {
                return []
            }
        }

        func _kind(of node: SyntaxProtocol) -> SwiftTypeDeclaration.Kind? {
            if node.is(StructDeclSyntax.self) {
                return .struct
            }
            if node.is(EnumDeclSyntax.self) {
                return .enum
            }
            if node.is(ClassDeclSyntax.self) {
                return .class
            }
            if node.is(ActorDeclSyntax.self) {
                return .actor
            }
            return nil
        }

        var types = [SwiftTypeDeclaration]()

        let collector = TypesDeclCollector(self)

        collector.all.forEach { node in
            if node.inheritanceClause?.trimmedDescription.contains(anyOf: ["View", "App", "PreviewProvider"]) == true {
                return
            }
            let name = node.name.text
            let properties = _properties(of: node)
            let cases = _cases(of: node)
            let kind = _kind(of: node)!
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: kind, name: name, properties: properties, cases: cases))
        }

        return SwiftFileDeclaration(name: name, path: path, types: types)

    }

}
