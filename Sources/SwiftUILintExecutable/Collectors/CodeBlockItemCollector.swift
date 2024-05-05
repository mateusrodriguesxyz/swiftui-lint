import SwiftSyntax

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
