//import SwiftSyntax
//
//final class NavigationViewOrStackFinder: SyntaxVisitor {
//
//    private(set) var decl: DeclReferenceExprSyntax?
//
//    private(set) var decls: [DeclReferenceExprSyntax] = []
//
//    private var skipNextClosureExprSyntax = false
//
//    package init() {
//        super.init(viewMode: .sourceAccurate)
//    }
//
//    func callAsFunction(_ node: SyntaxProtocol) -> DeclReferenceExprSyntax? {
//        if node.trimmedDescription.contains("Navigation") {
//            walk(node)
//        }
//        return decl
//    }
//
//    func search(_ node: SyntaxProtocol) -> [DeclReferenceExprSyntax] {
//        if node.trimmedDescription.contains("Navigation") {
//            walk(node)
//        }
//        return decls
//    }
//
//    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
//        if node.baseName.text == "NavigationView" || node.baseName.text == "NavigationStack" || node.baseName.text == "NavigationSplitView" {
//            decl = node
//            decls.append(node)
//        }
//        if node.baseName.text == "sheet" {
//            skipNextClosureExprSyntax = true
//        }
//        return .visitChildren
//    }
//
//    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
//        if skipNextClosureExprSyntax {
//            skipNextClosureExprSyntax = false
//            return .skipChildren
//        } else {
//            return .visitChildren
//        }
//    }
//
//}
