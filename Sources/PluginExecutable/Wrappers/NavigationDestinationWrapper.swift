import SwiftSyntax

struct NavigationDestinationWrapper {

    let decl: DeclReferenceExprSyntax

    var destination: FunctionCallExprSyntax? {

        var token: TokenSyntax? = decl.nextToken(viewMode: .sourceAccurate)

        while token?.text != "{" {
            token = token?.nextToken(viewMode: .sourceAccurate)
        }

        if let destination = token?._syntaxNode.parent?.as(ClosureExprSyntax.self)?.statements.first?.item.as(FunctionCallExprSyntax.self) {
            return destination
        }
        return nil
    }

    init?(_ decl: DeclReferenceExprSyntax) {
        if decl.baseName.trimmedDescription == "navigationDestination" {
            self.decl = decl
        } else {
            return nil
        }
    }

}
