import SwiftSyntax

final class ContainsNodeVisitor: SyntaxAnyVisitor {
    
    private let predicate: (Syntax) -> Bool

    private(set) var contains: Bool = false
    
    convenience init(named name: String, in closure: ClosureExprSyntax) {
        self.init(in: closure, where: { $0.as(DeclReferenceExprSyntax.self)?.baseName.text == name })
    }
    
    convenience init(node: SyntaxProtocol, in closure: ClosureExprSyntax) {
        self.init(in: closure, where: { $0.id == node.id })
    }
    
    init(in closure: ClosureExprSyntax, where predicate: @escaping (Syntax) -> Bool) {
        self.predicate = predicate
        super.init(viewMode: .sourceAccurate)
        walk(closure)
    }
    
    init(in node: SyntaxProtocol, where predicate: @escaping (Syntax) -> Bool) {
        self.predicate = predicate
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if predicate(node) {
            contains = true
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}
