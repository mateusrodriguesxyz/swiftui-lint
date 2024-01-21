import SwiftSyntax

final class ChildCollector: SyntaxVisitor {

    private(set) var children = [CodeBlockItemSyntax.Item]()

    init(_ view: SyntaxProtocol) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if let children = node.statements.as(CodeBlockItemListSyntax.self)?.map({ $0.item }) {
            if self.children.isEmpty {
                self.children = children
            }
        }
        return .skipChildren
    }

}
