import SwiftSyntax

struct StackDeclWrapper {

    let node: SyntaxProtocol

    var name: String {
        return node.trimmedDescription.prefix(while: { $0 != "{" && $0 != "(" }).trimmingCharacters(in: .whitespaces)
    }

    var closure: ClosureExprSyntax? {
        node.descendant(ClosureExprSyntax.self)
    }

    var children: [ViewChildWrapper] {
        return ChildrenCollector(node).children.compactMap({ ViewChildWrapper($0) })
    }

    init?(_ node: SyntaxProtocol) {
        if node.trimmedDescription.contains(anyOf: ["VStack", "HStack", "ZStack", "NavigationStack", "ScrollView", "Group"]) {
            self.node = node
        } else {
            return nil
        }
    }

}

extension SyntaxProtocol {

    func descendant<T: SyntaxProtocol>(_: T.Type) -> T? {
        DescendantCollector<T>(node: self).match
    }

}


final class DescendantCollector<T: SyntaxProtocol>: SyntaxAnyVisitor {

    private(set) var match: T? = nil

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
