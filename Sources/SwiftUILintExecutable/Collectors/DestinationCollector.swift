import SwiftSyntax

final class DestinationCollector: SyntaxVisitor {

    var destinations = [String]()
    
    private var markNextClosureChildren = false
    private var modalClosure: ClosureExprSyntax?
    
    private let targets: Set<String>

    init(_ node: SyntaxProtocol, context: Context) {
        self.targets = Set(context.views.map(\.name))
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let name = node.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text, targets.contains(name) {
            if modalClosure != nil {
                destinations.append("+" + name)
            } else {
                destinations.append(name)
            }
        }
        return .visitChildren
    }
    
    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text.is(anyOf: "sheet", "fullScreenCover", "popover") {
            markNextClosureChildren = true
        }
        return .visitChildren
    }
    
    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if markNextClosureChildren {
            modalClosure = node
        }
        return .visitChildren
    }
    
    override func visitPost(_ node: ClosureExprSyntax) {
        if node.id == modalClosure?.id {
            markNextClosureChildren = false
            modalClosure = nil
        }
    }

}
