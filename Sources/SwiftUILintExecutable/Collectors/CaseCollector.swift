import SwiftSyntax

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
