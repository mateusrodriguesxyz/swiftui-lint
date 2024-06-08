import SwiftSyntax

final class ClosureBindingCollector: SyntaxVisitor {

    private(set) var matches = [ClosureShorthandParameterSyntax]()

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: ClosureShorthandParameterSyntax) -> SyntaxVisitorContinueKind {
        matches.append(node)
        return .skipChildren
    }

}
