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

        var types = [SwiftTypeDeclaration]()

        let collector = TypesDeclCollector(self)

        collector.structs.forEach { node in
            if node.inheritanceClause?.trimmedDescription.contains(anyOf: ["View", "App", "PreviewProvider"]) == true {
                return
            }
            let name = node.name.text
            let properties = _properties(of: node)
            for property in properties {
                if property.type == nil {
                    Diagnostics.emit(.warning, message: "❌ \(self.name), '\(property.name)' type is nil", location: property.location)
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._struct, name: name, properties: properties, cases: []))
        }

        collector.classes.forEach { node in
            let name = node.name.text
            let properties = _properties(of: node)
            for property in properties {
                if property.type == nil {
                    Diagnostics.emit(.warning, message: "❌ \(self.name), '\(property.name)' type is nil", location: property.location)
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._class, name: name, properties: properties, cases: []))
        }

        collector.actors.forEach { node in
            let name = node.name.text
            let properties = _properties(of: node)
            for property in properties {
                if property.type == nil {
                    Diagnostics.emit(.warning, message: "❌ \(self.name), '\(property.name)' type is nil", location: property.location)
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._actor, name: name, properties: properties, cases: []))
        }

        collector.enums.forEach { node in
            let name = node.name.text
            let properties = _properties(of: node)
            let cases = CaseCollector(node).matches
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._enum, name: name, properties: properties, cases: cases))
        }

        return SwiftFileDeclaration(name: name, path: path, types: types)

    }

}
