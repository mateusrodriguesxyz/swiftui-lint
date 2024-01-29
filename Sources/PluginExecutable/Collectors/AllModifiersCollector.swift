import SwiftSyntax

final class AllModifiersCollector: SyntaxVisitor {

    struct Match {

        let decl: DeclReferenceExprSyntax
        let arguments: LabeledExprListSyntax

        var description: String {
            return "\(decl.trimmedDescription)(\(arguments.trimmedDescription))"
        }

    }

    private(set) var matches: [Match] = []

    private var decl: DeclReferenceExprSyntax?
    private var arguments: LabeledExprListSyntax?

    private var modifiersPosition: AbsolutePosition?

    init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        modifiersPosition = node.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition ?? node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if SwiftUIModifiers.all.contains(node.trimmedDescription) {
            if let modifiersPosition {
                if node.position >= modifiersPosition {
                    decl = node
                }
            } else {
                decl = node
            }
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if let decl {
            matches.append(Match(decl: decl, arguments: node))
            return .skipChildren
        }
        return .visitChildren
    }

}
