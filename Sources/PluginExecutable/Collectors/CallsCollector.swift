//import SwiftSyntax
//
//final class CallsCollector: SyntaxVisitor {
//
//    private(set) var calls = [FunctionCallExprSyntax]()
//
//    init(_ node: SyntaxProtocol) {
//        super.init(viewMode: .sourceAccurate)
//        walk(node)
//    }
//
//    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
//        calls.append(node)
//        return .visitChildren
//    }
//
//}
