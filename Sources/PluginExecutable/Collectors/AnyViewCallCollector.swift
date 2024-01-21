import SwiftSyntax

final class AnyViewCallCollector: SyntaxVisitor {

    let kinds: Set<String>

    var matches: [String: [FunctionCallExprSyntax]] = [:]

    init(kinds: Set<String>, node: SyntaxProtocol) {
        self.kinds = kinds
        for kind in kinds {
            matches[kind] = []
        }
        super.init(viewMode: .sourceAccurate)
        guard node.trimmedDescription.contains(anyOf: kinds) else {
            return
        }
        walk(node)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(anyOf: kinds) {
            return .visitChildren
        } else {
            return .skipChildren
        }
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        let kind = node.calledExpression.trimmedDescription
        if kinds.contains(kind) {
            matches[kind]?.append(node)
        }
        return .visitChildren
    }

}
