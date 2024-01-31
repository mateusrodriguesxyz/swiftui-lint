import SwiftSyntax

final class PropertyCollector: SyntaxVisitor {

    private(set) var properties = [PropertyDeclWrapper]()

    let target: SyntaxProtocol

    package init(_ node: SyntaxProtocol) {
        self.target = node
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        properties.append(PropertyDeclWrapper(decl: node))
        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if target.id == node.id { return .visitChildren }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if target.id == node.id { return .visitChildren }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if target.id == node.id { return .visitChildren }
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        if target.id == node.id { return .visitChildren }
        return .skipChildren
    }

}
