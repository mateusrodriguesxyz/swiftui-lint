import SwiftSyntax

extension SyntaxProtocol {

    func parent<S: SyntaxProtocol>(_ syntaxType: S.Type, where predicate: (S) -> Bool = { _ in true }, stop: (SyntaxProtocol?) -> Bool = { _ in false }) -> S? {
        var parent: SyntaxProtocol? = self
        while parent != nil, stop(parent) == false {
            if let _parent = parent?.as(S.self), predicate(_parent) {
                return _parent
            } else {
                parent = parent?.parent
            }
        }
        return nil
    }

}
