import SwiftSyntax

final class ModifierCollector: SyntaxVisitor {

    let modifiers: [String]

    private(set) var match: ModifierWrapper?

    private(set) var matches: [ModifierWrapper] = []

    private var decl: DeclReferenceExprSyntax?

    convenience init(modifier: String, _ node: StructDeclSyntax) {
        self.init(modifiers: [modifier], node)
    }

    init(modifiers: [String], _ node: StructDeclSyntax) {
        self.modifiers = modifiers
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if modifiers.contains(node.baseName.text) {
            decl = node
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if let decl {
            match = ModifierWrapper(name: decl.baseName.text, node: decl, expression: node.first)
            matches.append(match!)
            self.decl = nil
        }
        return .visitChildren
    }

}
