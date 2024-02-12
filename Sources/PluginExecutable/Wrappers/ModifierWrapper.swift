import SwiftSyntax

struct ModifierWrapper {

    let name: String
    let node: DeclReferenceExprSyntax
    let expression: LabeledExprSyntax?
    let content: SyntaxProtocol?

    init(name: String, node: DeclReferenceExprSyntax, expression: LabeledExprSyntax?) {
        self.name = name
        self.node = node
        self.expression = expression
        self.content = node.parent(CodeBlockItemSyntax.self)
    }

}
