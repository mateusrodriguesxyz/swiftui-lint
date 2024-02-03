//import SwiftSyntax
//
//struct SwiftPropertyDeclaration: Codable {
//
//    let location: SourceLocation
//    let description: String
//    let name: String
//    let attributes: Set<String>
//    let keywords: Set<String>
//    let hasInitializer: Bool
//    let type: TypeWrapper?
//
//}
//
//
//extension SwiftPropertyDeclaration {
//
//    init(_ property: PropertyDeclWrapper, file: FileWrapper, baseType: SyntaxProtocol? = nil, context: Context) {
//
//        let node = property.node.as(VariableDeclSyntax.self)!
//
//        self.location = file.location(of: node)
//        self.description = property.node.trimmedDescription
//        self.name = property.name
//        self.attributes = property.attributes
//        self.keywords = Set(node.modifiers.map(\.name.text) + [node.bindingSpecifier.text])
//        self.hasInitializer = property.hasInitializer
//        self.type = property._type(context, baseType: baseType)! // 😀
//    }
//
//}
