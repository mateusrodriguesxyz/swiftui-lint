//import SwiftSyntax
//
//final class ContainsCallVisitor: SyntaxVisitor {
//
//    let destination: String
//
//    private(set) var contains: Bool = false
//
//    init(destination: String, in closure: ClosureExprSyntax) {
//        self.destination = destination
//        super.init(viewMode: .sourceAccurate)
//        walk(closure)
//    }
//
//    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
//        if node.baseName.text == destination {
//            contains = true
//        }
//        return .skipChildren
//    }
//
//}
