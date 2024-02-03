import SwiftSyntax

struct ModifierWrapper {

    let name: String
    let decl: DeclReferenceExprSyntax
    let expression: LabeledExprSyntax?
    let content: SyntaxProtocol?

    init(name: String, decl: DeclReferenceExprSyntax, expression: LabeledExprSyntax?) {
        self.name = name
        self.decl = decl
        self.expression = expression
        self.content = decl.parent(CodeBlockItemSyntax.self)
    }

}
