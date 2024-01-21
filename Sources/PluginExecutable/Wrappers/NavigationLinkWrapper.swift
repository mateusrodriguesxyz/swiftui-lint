import SwiftSyntax

struct NavigationLinkWrapper {

    let call: FunctionCallExprSyntax

    var destination: FunctionCallExprSyntax? {
        if let destination = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(FunctionCallExprSyntax.self) {
            return destination
        }
        if let closure  = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(ClosureExprSyntax.self) ?? call.trailingClosure {
            if let destination = closure.statements.first?.item.as(FunctionCallExprSyntax.self) {
                return destination
            }
        }
        return nil
    }

    init?(_ call: FunctionCallExprSyntax) {
        if call.calledExpression.trimmedDescription == "NavigationLink" {
            self.call = call
        } else {
            return nil
        }
    }

}
