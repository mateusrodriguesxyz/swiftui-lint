import SwiftSyntax

final class LabeledExprFromTokenCollector: SyntaxVisitor {

    let token: TokenSyntax
    private(set) var match: LabeledExprSyntax?

    private var collect: Bool = false

    init(node: SyntaxProtocol, token: TokenSyntax) {
        self.token = token
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

}
