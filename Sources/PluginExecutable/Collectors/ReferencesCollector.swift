import SwiftSyntax

final class ReferencesCollector: SyntaxVisitor {

    private var parent: String?
//    private(set) var references = [(parent: String?, node: DeclReferenceExprSyntax)]()
    private(set) var references = [DeclReferenceExprSyntax]()

    package init(source: SourceFileSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(source)
    }

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let inheritanceClause = node.inheritanceClause, inheritanceClause.trimmedDescription.contains("View") {
            parent = node.name.text
        }
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        parent = nil
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        references.append(node)
        return .visitChildren
    }

}
