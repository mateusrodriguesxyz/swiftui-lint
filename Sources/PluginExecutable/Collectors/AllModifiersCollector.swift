import SwiftSyntax

final class AllModifiersCollector: SyntaxVisitor {

    struct Match {

        let decl: DeclReferenceExprSyntax
        let arguments: LabeledExprListSyntax

        var description: String {
            return "\(decl.trimmedDescription)(\(arguments.trimmedDescription))"
        }

    }

    var matches: [Match] = []

    var decl: DeclReferenceExprSyntax?
    var arguments: LabeledExprListSyntax?

    var modifiersPosition: AbsolutePosition?

    init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        modifiersPosition = node.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition ?? node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if BrokenModifierCallCollector.modifiers.contains(node.trimmedDescription) {
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
        }
        return .visitChildren
    }

}
