import SwiftSyntax

final class ReferenceCollector: SyntaxVisitor {
    
    private(set) var name: String

    private(set) var reference: SyntaxProtocol?

    init(_ name: String, in node: SyntaxProtocol) {
        self.name = name
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text == name {
            reference = node
        }
        return .visitChildren
    }


}
