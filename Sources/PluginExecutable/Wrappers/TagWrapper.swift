import SwiftSyntax

struct TagWrapper {

    let node: LabeledExprSyntax

    var value: String  {
        node.expression.trimmedDescription.replacingOccurrences(of: #"""#, with: "")
    }

    func type(_ context: Context) -> TypeWrapper? {
        TypeWrapper(node.expression) ?? TypeWrapper(node.expression, in: context)
    }

}

extension SyntaxProtocol {

    func tag() -> TagWrapper? {
        if let node = self.parent(CodeBlockItemSyntax.self) {
            if let tag = CallCollector(name: "tag", node).matches.first {
                return TagWrapper(node: tag.arguments.first!)
            }
        }
        return nil
    }

}
