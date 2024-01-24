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

final class CaseCollector: SyntaxVisitor {

    private(set) var matches = [String]()

    package init(_ node: EnumDeclSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
        matches.append(node.name.text)
        return .skipChildren
    }

}
