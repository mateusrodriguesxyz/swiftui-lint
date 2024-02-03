import SwiftSyntax

final class AllModifiersCollector: SyntaxVisitor {

    struct Match {

        let decl: DeclReferenceExprSyntax
        let arguments: LabeledExprListSyntax
        let closure: ClosureExprSyntax?

//        var description: String {
//            return "\(decl.trimmedDescription)(\(arguments.trimmedDescription))"
//        }

    }

    private(set) var matches: [Match] = []

    private var decl: DeclReferenceExprSyntax?
    private var arguments: LabeledExprListSyntax?
    private var closure: ClosureExprSyntax?

    var modifiersPosition: AbsolutePosition?

    init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)

        let node = node.parent(CodeBlockItemSyntax.self)!

        var token = node.firstToken(viewMode: .sourceAccurate)

        while token?.text != "{" && token != nil {
            let next = token?.nextToken(viewMode: .sourceAccurate)
            token = next
            if let next, SwiftUIModifiers.builtin.contains(next.text) {
                token = nil
            }
            if let endPosition = token?.endPosition, endPosition > node.endPosition {
                token = nil
            }
        }

        if token != nil {
            if let closure = token?.parent(ClosureExprSyntax.self), closure.parent?.is(FunctionCallExprSyntax.self) == true {
                modifiersPosition = closure.endPosition
            }
        }


//        modifiersPosition = node.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition ?? node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.as(FunctionCallExprSyntax.self)?.trailingClosure?.endPosition
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if SwiftUIModifiers.builtin.contains(node.trimmedDescription) {
            if let modifiersPosition {
                if node.position >= modifiersPosition {
                    if let decl, let arguments {
                        matches.append(Match(decl: decl, arguments: arguments, closure: closure))
                        self.arguments = nil
                        self.closure = nil
                    }
                    decl = node
                }
            } else {
                if let decl, let arguments {
                    matches.append(Match(decl: decl, arguments: arguments, closure: closure))
                    self.arguments = nil
                    self.closure = nil
                }
                decl = node
            }
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        self.arguments = node
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        self.closure = node
        return .skipChildren
    }

    override func visitPost(_ node: CodeBlockItemSyntax) {
        if let decl, let arguments {
            matches.append(Match(decl: decl, arguments: arguments, closure: closure))
        }
    }

    func matches(_ modifiers: String...) -> [Match] {
        return matches.filter({ $0.decl.trimmedDescription.contains(anyOf: modifiers) })
    }

}
