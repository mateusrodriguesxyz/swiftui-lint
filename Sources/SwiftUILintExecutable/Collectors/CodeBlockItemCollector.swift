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

final class BlockCollector: SyntaxVisitor {

    private(set) var block: SyntaxProtocol?

    init(_ node: SyntaxProtocol) {
        super.init(viewMode: .fixedUp)
        walk(node)
    }

    override func visit(_ node: AccessorBlockSyntax) -> SyntaxVisitorContinueKind {
        self.block = node
        return .skipChildren
    }
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        self.block = node
        return .skipChildren
    }

}
