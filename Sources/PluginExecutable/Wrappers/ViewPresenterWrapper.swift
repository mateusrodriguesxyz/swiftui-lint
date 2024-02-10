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
    
    enum Node {
        case call(FunctionCallExprSyntax)
        case decl(DeclReferenceExprSyntax)
    }
    
    private let _node: Node
    
    var node: SyntaxProtocol {
        switch _node {
        case .call(let node):
            return node
        case .decl(let node):
            return node
        }
    }

    let kind: Kind

    let identifier: String

    var destination: FunctionCallExprSyntax? {
        
        switch _node {
        case .call(let call):
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
            
            return nil
        case .decl(let decl):
            var token: TokenSyntax? = decl.nextToken(viewMode: .sourceAccurate)

            while token?.text != "{" {
                token = token?.nextToken(viewMode: .sourceAccurate)
            }
            
            // navigationDestination, sheet, fullScreenCover, popover
            if let destination = token?._syntaxNode.parent?.as(ClosureExprSyntax.self)?.statements.first?.item.as(FunctionCallExprSyntax.self) {
                return destination
            }
            
            return nil
        }
        
//        if let call = node.as(FunctionCallExprSyntax.self) {
//           
//            // NavigationLink(destination:)
//            if let destination = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(FunctionCallExprSyntax.self) {
//                return destination
//            }
//            
//            // NavigationLink(destination: { })
//            if let closure = call.arguments.first(where: { $0.label?.text == "destination" })?.expression.as(ClosureExprSyntax.self) {
//                return closure.statements.first?.item.as(FunctionCallExprSyntax.self)
//            }
//            
//            // NavigationLink { }
//            if let closure = call.trailingClosure {
//                return closure.statements.first?.item.as(FunctionCallExprSyntax.self)
//            }
//            
//        }
//
//        if let decl = node.as(DeclReferenceExprSyntax.self) {
//
//            var token: TokenSyntax? = decl.nextToken(viewMode: .sourceAccurate)
//
//            while token?.text != "{" {
//                token = token?.nextToken(viewMode: .sourceAccurate)
//            }
//            
//            // navigationDestination, sheet, fullScreenCover, popover
//            if let destination = token?._syntaxNode.parent?.as(ClosureExprSyntax.self)?.statements.first?.item.as(FunctionCallExprSyntax.self) {
//                return destination
//            }
//
//        }
//
//        return nil
    }

    init?(node: FunctionCallExprSyntax) {
        if node.calledExpression.trimmedDescription == "NavigationLink" {
            self._node = .call(node)
            self.identifier = node.calledExpression.trimmedDescription
            self.kind = .navigation
        } else {
            return nil
        }
    }

    init?(node: DeclReferenceExprSyntax) {
        if let kind = ViewPresenterWrapper.Kind(node.baseName.trimmedDescription) {
            self._node = .decl(node)
            self.identifier = node.baseName.text
            self.kind = kind
        } else {
            return nil
        }
    }

}
