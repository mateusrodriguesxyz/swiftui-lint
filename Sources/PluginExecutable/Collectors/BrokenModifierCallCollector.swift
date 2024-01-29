import SwiftSyntax

final class BrokenModifierCallCollector: SyntaxVisitor {

    private(set) var calls = [DeclReferenceExprSyntax]()

    package init(_ view: StructDeclSyntax) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: DoStmtSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: CatchClauseSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: ConditionElementListSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: AwaitExprSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.signature.returnClause?.type.trimmedDescription == "some View" else { return .skipChildren }
        return .visitChildren

    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.bindings.first?.typeAnnotation?.type.trimmedDescription == "some View" else { return .skipChildren }
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if let identifier = node.previousToken(viewMode: .all)?.text, SwiftUIModifiers.actions.contains(identifier) {
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

    override func visitPost(_ node: DeclReferenceExprSyntax) {

        guard checkDeclIsValid(node) else { return }

        if node.previousToken(viewMode: .sourceAccurate)?.text == "switch" { return }

        if node.previousToken(viewMode: .sourceAccurate)?.text != ".", node.previousToken(viewMode: .sourceAccurate)?.text != "(", node.previousToken(viewMode: .sourceAccurate)?.text != ":" {

            if node.nextToken(viewMode: .sourceAccurate)?.text != "(", node.nextToken(viewMode: .sourceAccurate)?.text != "{" { return }

            calls.append(node)

        }

    }

    func checkDeclIsValid(_ node: DeclReferenceExprSyntax) -> Bool {
        SwiftUIModifiers.builtin.contains(node.baseName.text) || SwiftUIModifiers.custom.contains(node.baseName.text)
    }

}
