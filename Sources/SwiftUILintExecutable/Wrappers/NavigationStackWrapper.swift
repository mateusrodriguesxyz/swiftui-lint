//import SwiftSyntax
//
//struct NavigationStackWrapper {
//
//    let node: FunctionCallExprSyntax
//
//    var content: ClosureExprSyntax? {
//        return node.trailingClosure
//    }
//
//    init?(_ decl: DeclReferenceExprSyntax) {
//        if decl.baseName.text == "NavigationStack", let parent = decl.parent?.as(FunctionCallExprSyntax.self) {
//            self.node = parent
//        } else {
//            return nil
//        }
//
//    }
//
//}
