import SwiftSyntax

struct ViewChildWrapper {

    let node: SyntaxProtocol

    var name: String {
        if node.trimmedDescription.contains("#if") {
            return "#if ... #endif"
        } else {
            let name = node.firstToken(viewMode: .all)!.text
            if name == "Color" {
                return node.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription ?? name
            } else {
                return name         
            }
        }
    }

    var arguments: LabeledExprListSyntax? {
        return node.as(FunctionCallExprSyntax.self)?.arguments
    }

}
