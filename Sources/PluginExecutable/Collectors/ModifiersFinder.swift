import SwiftSyntax

extension SyntaxProtocol {

    func parent<S: SyntaxProtocol>(_ syntaxType: S.Type, where predicate: (S) -> Bool = { _ in true }) -> S? {
        var parent: SyntaxProtocol? = self
        while parent != nil {
            if let _parent = parent?.as(S.self), predicate(_parent) {
                return _parent
            } else {
                parent = parent?.parent
            }
        }
        return nil
    }

}

struct ModifiersFinder {

    struct Match {
        let modifier: String
        let node: SyntaxProtocol
    }

    let modifiers: [String]

    func callAsFunction(_ node: SyntaxProtocol?, file: FileWrapper? = nil) -> [Match] {

        let modifiersFirstToken = node?.lastToken(viewMode: .sourceAccurate)

        let modifiersLastToken = node?.parent(CodeBlockItemSyntax.self)?.lastToken(viewMode: .fixedUp)

//        if let file, let modifiersFirstToken, let modifiersLastToken {
//            Diagnostics.emit(.warning, message: "Modifiers First Token", node: modifiersFirstToken, file: file)
//            Diagnostics.emit(.warning, message: "Modifiers Last Token", node: modifiersLastToken, file: file)
//        }

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

struct ViewCallWrapper {

    let node: CodeBlockItemSyntax

    init?(_ node: SyntaxProtocol) {
        if let node = node.parent(CodeBlockItemSyntax.self) {
            self.node = node
        } else {
            return nil
        }
    }

    func matches(_ modifiers: [String]) -> [ModifiersFinder.Match] {
        ModifiersFinder(modifiers: modifiers)(node)
    }

}
