import SwiftSyntax

struct NavigationSplitViewWrapper {

    let node: FunctionCallExprSyntax

    var sidebar: ClosureExprSyntax? {
        return node.trailingClosure
    }

//    var content: ClosureExprSyntax? {
//        if node.additionalTrailingClosures.count == 2 {
//            return node.additionalTrailingClosures.first?.closure
//        } else {
//            return nil
//        }
//    }
//
//    var detail: ClosureExprSyntax? {
//        return node.additionalTrailingClosures.last?.closure
//    }

    init?(_ decl: DeclReferenceExprSyntax) {
        if decl.baseName.text == "NavigationSplitView", let parent = decl.parent?.as(FunctionCallExprSyntax.self) {
            self.node = parent
        } else {
            return nil
        }

    }

    init?(_ node: FunctionCallExprSyntax) {
        if node.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text == "NavigationSplitView" {
            self.node = node
        } else {
            return nil
        }
    }

}
