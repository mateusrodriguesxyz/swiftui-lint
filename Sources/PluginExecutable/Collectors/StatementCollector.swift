//import SwiftSyntax
//
//final class StatementCollector: SyntaxVisitor {
//
//    private(set) var statement: SyntaxProtocol?
//
//    package init(_ node: SyntaxProtocol) {
//        super.init(viewMode: .sourceAccurate)
//        walk(node)
//    }
//
//    override func visit(_ node: ExpressionStmtSyntax) -> SyntaxVisitorContinueKind {
//        statement = node
//        return .visitChildren
//    }
//
//    override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
//        statement = node
//        return .visitChildren
//    }
//
//}
