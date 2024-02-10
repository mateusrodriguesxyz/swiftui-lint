import SwiftSyntax

//final class ContainsNodeVisitor: SyntaxAnyVisitor {
//
//    private let node: SyntaxProtocol
//
//    private(set) var contains: Bool = false
//    
//    init(node: SyntaxProtocol, in closure: ClosureExprSyntax) {
//        self.node = node
//        super.init(viewMode: .sourceAccurate)
//        walk(closure)
//    }
//
//    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
//        if node.id == self.node.id {
//            contains = true
//            return .skipChildren
//        } else {
//            return .visitChildren
//        }
//    }
//
//}

final class _ContainsNodeVisitor: SyntaxAnyVisitor {
    
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

    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if predicate(node) {
            contains = true
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}

