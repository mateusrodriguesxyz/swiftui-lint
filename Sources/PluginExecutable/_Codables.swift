import SwiftSyntax

// MARK: View

struct SwiftUIViewTypeDeclaration: Codable {
    
    let location: SourceLocation
    let name: String
    let properties: [SwiftPropertyDeclaration]
    let destinations: [String]
    
}

extension SwiftUIViewTypeDeclaration {
    
    init(_ view: ViewDeclWrapper, context: Context) {
        self.location = view.file.location(of: view.node)
        self.name = view.name
        self.properties = view.properties.compactMap({ SwiftPropertyDeclaration($0, file: view.file, baseType: view.node, context: context) })
        self.destinations = context.destinations[view.name, default: []]
    }
    
}



// MARK: Model

struct SwiftModelTypeDeclaration: Codable {

    enum Kind: Codable {
        
        case `struct`
        case `class`
        case `actor`
        case `enum`
        
        init?(node: TypeDeclSyntaxProtocol) {
            if node is StructDeclSyntax {
                self = .struct
                return
            }
            if node is ClassDeclSyntax {
                self = .class
                return
            }
            if node is ActorDeclSyntax {
                self = .actor
                return
            }
            if node is EnumDeclSyntax {
                self = .enum
                return
            }
            return nil
        }
        
        
    }

    let location: SourceLocation
    let kind: Kind
    let name: String
    let properties: [SwiftPropertyDeclaration]

    enum CodingKeys: String, CodingKey {
        case location
        case name = "_0_name"
        case kind = "_1_kind"
        case properties
    }

    init(_ node: TypeDeclSyntaxProtocol, file: FileWrapper, context: Context) {
        self.location = file.location(of: node)
        self.kind = Kind(node: node)!
        self.name = node.name.text
        self.properties = node.properties(context).compactMap {
            SwiftPropertyDeclaration($0, file: file, baseType: node, context: context)
        }
//        self.cases = []
    }

}

extension SwiftModelTypeDeclaration: CustomStringConvertible {
    var description: String {
        return "name: \(self.name)\nkind: \(kind)\nproperties: \(properties)"
    }
}


// MARK: Properties

struct SwiftPropertyDeclaration: Codable {

    let location: SourceLocation
    let name: String
    let attributes: Set<String>
    let keywords: Set<String>
    let hasInitializer: Bool
    let type: TypeWrapper?

}

extension SwiftPropertyDeclaration {

    init?(_ property: PropertyDeclWrapper, file: FileWrapper, baseType: TypeDeclSyntaxProtocol? = nil, context: Context) {

        guard let type = property._type(context, baseType: baseType) else {
            return nil
        }
        
        let node = property.node.as(VariableDeclSyntax.self)!

        self.location = file.location(of: node)
        self.name = property.name
        self.attributes = property.attributes
        self.keywords = Set(node.modifiers.map(\.name.text) + [node.bindingSpecifier.text])
        self.hasInitializer = property.hasInitializer
        self.type = type // 😀
    }

}

extension SwiftPropertyDeclaration: CustomStringConvertible {
    var description: String {
        return "(name: \(self.name), type: \(type?.description ?? "nil"))"
    }
}
