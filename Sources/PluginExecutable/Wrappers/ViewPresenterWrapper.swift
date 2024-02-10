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

    let identifier: String

    var destination: FunctionCallExprSyntax? {
        
        if let call = node.as(FunctionCallExprSyntax.self) {
            // NavigationLink(destination:)
            if let destination = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(FunctionCallExprSyntax.self) {
                return destination
            }
            // NavigationLink(destination: { })
            if let closure = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(ClosureExprSyntax.self) {
                return closure.statements.first?.item.as(FunctionCallExprSyntax.self)
            }
            // NavigationLink { }
            if let closure = call.trailingClosure {
                return closure.statements.first?.item.as(FunctionCallExprSyntax.self)
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

    init?(node: FunctionCallExprSyntax) {
        if node.calledExpression.trimmedDescription == "NavigationLink" {
            self.node = node
            self.identifier = node.calledExpression.trimmedDescription
            self.kind = .navigation
        } else {
            return nil
        }
    }

    init?(node: DeclReferenceExprSyntax) {
        if let kind = ViewPresenterWrapper.Kind(node.baseName.trimmedDescription) {
            self.node = node
            self.identifier = node.baseName.text
            self.kind = kind
        } else {
            return nil
        }
    }

}
