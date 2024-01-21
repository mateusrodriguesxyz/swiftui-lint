import SwiftSyntax

struct ViewChildWrapper {

    let node: SyntaxProtocol

    var name: String {

//        if let node = node.as(PostfixIfConfigExprSyntax.self)?.base?.as(FunctionCallExprSyntax.self) {
//            return node.firstToken(viewMode: .all)!.text
//        }

//        if node.trimmedDescription.contains("#if") {
//            return "#if ... #endif"
//        } else {
//            let name = node.firstToken(viewMode: .all)!.text
//            if name == "Color" {
//                return node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription ?? name
//            } else {
//                return name         
//            }
//        }

        let name = node.firstToken(viewMode: .all)!.text
        
        if name == "Color" {
            return node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription ?? name
        } else {
            return name
        }

    }

    var arguments: LabeledExprListSyntax? {
        if let node = node.as(PostfixIfConfigExprSyntax.self)?.base?.as(FunctionCallExprSyntax.self) {
            return node.arguments
        } else {
            return node.as(FunctionCallExprSyntax.self)?.arguments
        }
    }

    init(node: SyntaxProtocol) {
        self.node = node
    }

    init?(_ node: SyntaxProtocol) {
        if node.is(VariableDeclSyntax.self) {
            return nil
        }
        self.node = node
    }

}
