import SwiftSyntax

final class ContainsNodeVisitor: SyntaxAnyVisitor {

    private let node: SyntaxProtocol

    private(set) var contains: Bool = false

    init(node: SyntaxProtocol, in closure: ClosureExprSyntax) {
        self.node = node
        super.init(viewMode: .sourceAccurate)
        walk(closure)
    }

    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if node.id == self.node.id {
            contains = true
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}
