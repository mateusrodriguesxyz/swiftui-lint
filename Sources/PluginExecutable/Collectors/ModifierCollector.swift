import SwiftSyntax

final class ModifierCollector: SyntaxVisitor {

    let modifier: String

    private(set) var match: ModifierWrapper?

    private(set) var matches: [ModifierWrapper] = []

    private var decl: DeclReferenceExprSyntax?

    init(modifier: String, _ node: StructDeclSyntax) {
        self.modifier = modifier
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text == modifier {
            decl = node
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if let decl {
            match = ModifierWrapper(name: modifier, decl: decl, expression: node.first)
            matches.append(match!)
            self.decl = nil
        }
        return .visitChildren
    }

}
