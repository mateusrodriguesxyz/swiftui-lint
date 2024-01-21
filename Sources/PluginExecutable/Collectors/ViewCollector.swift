import SwiftSyntax

final class ViewCollector: SyntaxVisitor {

    private(set) var views = [StructDeclSyntax]()

    init(source: SourceFileSyntax) {
        super.init(viewMode: .fixedUp)
        walk(source)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let inheritanceClause = node.inheritanceClause, inheritanceClause.trimmedDescription.contains("View") {
            views.append(node)
        }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

}

struct TagWrapper {

    let node: LabeledExprSyntax

    func type(_ context: Context) -> TypeWrapper? {
        TypeWrapper(node.expression) ?? TypeWrapper(node.expression, in: context)
    }

}

extension SyntaxProtocol {

    func tag(in parent: FunctionCallExprSyntax) -> TagWrapper? {
        if let modifier = ModifierFirstCallFinder(modifier: "tag")(self), let node = ModifierValueCollector(parent, position: modifier.node.position).match {
            return TagWrapper(node: node)
        } else {
            return nil
        }
    }

    func tag2(in parent: FunctionCallExprSyntax) -> TagWrapper? {
        if let node = self.parent(CodeBlockItemSyntax.self) {
            if let tag = CallCollector(name: "tag", node).matches.first {
                return TagWrapper(node: tag.arguments.first!)
            }
        }
        return nil
    }

    func tag() -> TagWrapper? {
        if let node = self.parent(CodeBlockItemSyntax.self) {
            if let tag = CallCollector(name: "tag", node).matches.first {
                return TagWrapper(node: tag.arguments.first!)
            }
        }
        return nil
    }


}
