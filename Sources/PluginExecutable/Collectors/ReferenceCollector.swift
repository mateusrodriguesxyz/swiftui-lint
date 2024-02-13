import SwiftSyntax

final class ReferenceCollector: SyntaxVisitor {

    private(set) var references = [DeclReferenceExprSyntax]()

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        references.append(node)
        return .visitChildren
    }

}
