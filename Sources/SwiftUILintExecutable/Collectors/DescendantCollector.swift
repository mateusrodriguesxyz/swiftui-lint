import SwiftSyntax

final class DescendantCollector<T: SyntaxProtocol>: SyntaxAnyVisitor {

    private(set) var match: T?

    init(node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if let node = node.as(T.self), match == nil {
            self.match = node
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}

extension SyntaxProtocol {

    func descendant<T: SyntaxProtocol>(_: T.Type) -> T? {
        DescendantCollector<T>(node: self).match
    }

}
