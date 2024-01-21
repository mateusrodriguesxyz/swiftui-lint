import SwiftSyntax

final class ChildrenCollector: SyntaxVisitor {

    private(set) var children = [CodeBlockItemSyntax.Item]()

    init(_ view: SyntaxProtocol) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        
        let children = node.statements.map(\.item)
        
        if self.children.isEmpty {
            self.children = children.flatMap { node in
                if node.is(ExpressionStmtSyntax.self) {
                    return CodeBlockItemCollector(node).children
                }
                if node.is(IfConfigDeclSyntax.self) {
                    return CodeBlockItemCollector(node).children
                }
                return [node]
            }
        }

        return .skipChildren
    }

}

final class CodeBlockItemCollector: SyntaxVisitor {

    private(set) var children = [CodeBlockItemSyntax.Item]()

    init(_ view: SyntaxProtocol) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        children.append(node.item)
        return .skipChildren
    }

}
