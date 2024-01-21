import SwiftSyntax

struct ModifierFirstCallFinder {

    struct Match {
        let modifier: String
        let node: SyntaxProtocol
    }

    let modifier: String

    func callAsFunction(_ node: SyntaxProtocol?) -> Match? {

        var token = node?.firstToken(viewMode: .sourceAccurate)

        while token != nil {
            if token?.text == modifier, let node = token?._syntaxNode {
                return Match(modifier: modifier, node: node)
            }
            token = token?.nextToken(viewMode: .sourceAccurate)
        }

        return nil

    }

}
