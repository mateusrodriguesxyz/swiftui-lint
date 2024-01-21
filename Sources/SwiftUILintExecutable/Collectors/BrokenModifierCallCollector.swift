import SwiftSyntax

final class BrokenModifierCallCollector: SyntaxVisitor {

    private(set) var calls = [DeclReferenceExprSyntax]()

    package init(_ view: StructDeclSyntax, file: FileWrapper? = nil) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.signature.returnClause?.type.trimmedDescription == "some View" else { return .skipChildren }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
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

        guard SwiftUIModifiers.all.contains(node.baseName.text) else { return }

        if node.previousToken(viewMode: .sourceAccurate)?.text == "switch" { return }

        if node.previousToken(viewMode: .sourceAccurate)?.text != ".", node.previousToken(viewMode: .sourceAccurate)?.text != "(", node.previousToken(viewMode: .sourceAccurate)?.text != ":" {

            if node.nextToken(viewMode: .sourceAccurate)?.text != "(", node.nextToken(viewMode: .sourceAccurate)?.text != "{" { return }

            calls.append(node)

        }

    }

}
