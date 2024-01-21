import SwiftSyntax

final class FunctionCollector: SyntaxVisitor {

    private(set) var functions = [FunctionDeclWrapper]()

    init(_ view: StructDeclSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(view)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        functions.append(FunctionDeclWrapper(node))
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

}
