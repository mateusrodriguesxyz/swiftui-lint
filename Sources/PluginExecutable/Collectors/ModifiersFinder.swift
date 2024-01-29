import SwiftSyntax

struct ModifiersFinder {

    struct Match {
        let modifier: String
        let node: SyntaxProtocol
    }

    let modifiers: [String]

    func callAsFunction(_ node: SyntaxProtocol?, file: FileWrapper? = nil) -> [Match] {

        let modifiersFirstToken = node?.lastToken(viewMode: .sourceAccurate)

        let modifiersLastToken = node?.parent(CodeBlockItemSyntax.self)?.lastToken(viewMode: .fixedUp)

        var matches: [Match] = []

        var token = modifiersFirstToken

        while token != nil {
            if let modifiersLastPosition = modifiersLastToken?.endPosition, token!.endPosition > modifiersLastPosition {
                return matches
            } else {
//                print("keep searching...", token?.text, token?.endPosition.utf8Offset)
            }
            for modifier in modifiers {
                if token?.text == modifier, let node = token?._syntaxNode {
                    matches.append(Match(modifier: modifier, node: node))
                }
            }
            token = token?.nextToken(viewMode: .sourceAccurate)
        }

        return matches

    }

}
