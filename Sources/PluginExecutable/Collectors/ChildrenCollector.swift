import SwiftSyntax

final class ChildrenCollector: SyntaxVisitor {

    private(set) var children = [CodeBlockItemSyntax.Item]()

    init(_ view: SyntaxProtocol) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if let children = node.statements.as(CodeBlockItemListSyntax.self)?.map({ $0.item }) {
            if self.children.isEmpty {
//                self.children = children
                self.children = children.flatMap { node in
                    if node.is(ExpressionStmtSyntax.self) {
                        return ExpressionStmtChildCollector(node).children
                    } else {
                        return [node]
                    }
                }
            }
        }
        return .skipChildren
    }

}

final class ExpressionStmtChildCollector: SyntaxVisitor {

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
