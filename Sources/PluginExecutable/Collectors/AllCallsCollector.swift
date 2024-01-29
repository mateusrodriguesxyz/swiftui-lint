import SwiftSyntax

final class AllCallsCollector: SyntaxVisitor {

    private(set) var calls = [FunctionCallExprSyntax]()

    init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        calls.append(node)
        return .visitChildren
    }

}

final class ViewCallCollector: SyntaxVisitor {

    private let names: Set<String>
    private let skipChildrenOf: String?

    private var skipNextClosureExprSyntax = false

    private(set) var calls = [FunctionCallExprSyntax]()

    init(_ names: [String], skipChildrenOf: String? = nil, from node: SyntaxProtocol) {
        self.names = Set(names)
        self.skipChildrenOf = skipChildrenOf
        super.init(viewMode: .sourceAccurate)
        guard node.trimmedDescription.contains(anyOf: names) else {
            return
        }
        walk(node)
    }

    convenience init(_ name: String, skipChildrenOf: String? = nil, from node: SyntaxProtocol) {
        self.init([name], skipChildrenOf: skipChildrenOf, from: node)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(anyOf: names) {
            return .visitChildren
        } else {
            return .skipChildren
        }
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if names.contains(node.calledExpression.trimmedDescription) {
            calls.append(node)
        }
        return .visitChildren
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if let skipChildrenOf, node.baseName.text == skipChildrenOf {
            skipNextClosureExprSyntax = true
        }
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if skipNextClosureExprSyntax {
            skipNextClosureExprSyntax = false
            return .skipChildren
        } else {
            return .visitChildren
        }
    }


}
