import SwiftSyntax

final class PropertyCollector: SyntaxVisitor {

    private(set) var properties = [PropertyDeclWrapper]()

    package init(source: SourceFileSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(source)
    }

    package init(_ view: StructDeclSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(view)
    }

    package init(_ node: SyntaxProtocol) {
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

}
