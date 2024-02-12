import SwiftSyntax

final class AppliedModifiersCollector: SyntaxVisitor {

    struct Match {

        let decl: DeclReferenceExprSyntax
        let arguments: LabeledExprListSyntax
        let closure: ClosureExprSyntax?
        
        var name: String {
            return decl.baseName.text
        }

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

        while token?.text != "{" && token != nil && token!.endPosition < node.endPosition {
            let next = token?.nextToken(viewMode: .sourceAccurate)
            token = next
            if let next, SwiftUIModifiers.builtin.contains(next.text) {
                token = nil
            }
        }

        if token != nil {
            if let closure = token?.parent(ClosureExprSyntax.self), closure.parent?.is(FunctionCallExprSyntax.self) == true {
                modifiersPosition = closure.endPosition
            }
        }
        
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if SwiftUIModifiers.builtin.contains(node.trimmedDescription) {
            if let modifiersPosition {
                if node.position >= modifiersPosition {
                    buildMatch()
                    decl = node
                }
            } else {
                buildMatch()
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
        buildMatch()
    }
    
    private func buildMatch() {
        if let decl, let arguments {
            matches.append(Match(decl: decl, arguments: arguments, closure: closure))
            self.arguments = nil
            self.closure = nil
        }
    }

}

extension AppliedModifiersCollector {
    
    func matches(_ modifiers: String...) -> [Match] {
        return matches.filter({ $0.decl.trimmedDescription.contains(anyOf: modifiers) })
    }
    
    @_disfavoredOverload
    func matches(_ modifiers: [String]) -> [Match] {
        return matches.filter({ $0.decl.trimmedDescription.contains(anyOf: modifiers) })
    }
    
}
