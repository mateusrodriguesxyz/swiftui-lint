import SwiftSyntax

struct ViewPresenterWrapper {

    enum Kind: Equatable {

        case navigation
        case modal(_ modifier: String)

        init?(_ modifier: String) {
            if modifier == "navigationDestination" {
                self = .navigation
            } else if ["sheet", "fullScreenCover", "popover"].contains(modifier) {
                self = .modal(modifier)
            } else {
                return nil
            }
        }

    }

    let node: SyntaxProtocol
//    let parent: String?
    let kind: Kind

//    var isModal: Bool {
//        switch kind {
//            case .navigation:
//                return false
//            case .modal:
//                return true
//        }
//    }

    var identifier: String {
        if let node = node.as(FunctionCallExprSyntax.self) {
            return node.calledExpression.trimmedDescription
        }
        if let node = node.as(DeclReferenceExprSyntax.self) {
            return node.baseName.text
        }
        return "nil"
    }

    var destination: FunctionCallExprSyntax? {

        if let call = node.as(FunctionCallExprSyntax.self) {
            if let destination = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(FunctionCallExprSyntax.self) {
                return destination
            }
            if let closure  = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(ClosureExprSyntax.self) ?? call.trailingClosure {
                if let destination = closure.statements.first?.item.as(FunctionCallExprSyntax.self) {
                    return destination
                }
            }
        }

        if let decl = node.as(DeclReferenceExprSyntax.self) {

            var token: TokenSyntax? = decl.nextToken(viewMode: .sourceAccurate)

            while token?.text != "{" {
                token = token?.nextToken(viewMode: .sourceAccurate)
            }

            if let destination = token?._syntaxNode.parent?.as(ClosureExprSyntax.self)?.statements.first?.item.as(FunctionCallExprSyntax.self) {
                return destination
            }

        }

        return nil
    }

    init?(node: FunctionCallExprSyntax/*, parent: String?*/) {
        if node.calledExpression.trimmedDescription == "NavigationLink" {
            self.node = node
//            self.parent = parent
            self.kind = .navigation
        } else {
            return nil
        }
    }

    init?(node: DeclReferenceExprSyntax/*, parent: String?*/) {
        if let kind = ViewPresenterWrapper.Kind(node.baseName.trimmedDescription) {
            self.node = node
//            self.parent = parent
            self.kind = kind
        } else {
            return nil
        }
    }

}
