import SwiftSyntax

final class SheetContentCollector: SyntaxVisitor {

    var matches: [ClosureExprSyntax] = []

    var collectClosure = false

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        guard node.trimmedDescription.contains(anyOf: ["sheet", "popover", "fullScreenCover"]) else { return }
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.trimmedDescription.contains(anyOf: ["sheet", "popover", "fullScreenCover"]) {
            collectClosure = true
        }
        return .skipChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if collectClosure {
            matches.append(node)
            collectClosure = false
        }
        return .visitChildren
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(anyOf: ["sheet", "popover", "fullScreenCover"]) {
            return .visitChildren
        } else {
            return .skipChildren
        }

    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

}
