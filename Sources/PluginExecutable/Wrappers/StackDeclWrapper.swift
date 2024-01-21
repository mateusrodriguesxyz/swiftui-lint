import SwiftSyntax

struct StackDeclWrapper {

    let node: SyntaxProtocol

    var name: String {
        return node.trimmedDescription.prefix(while: { $0 != "{" && $0 != "(" }).trimmingCharacters(in: .whitespaces)
    }

    var children: [ViewChildWrapper] {
        return ChildCollector(node).children.map({ ViewChildWrapper(node: $0) })
    }

    init?(_ node: SyntaxProtocol) {
        if node.trimmedDescription.contains(anyOf: ["VStack", "HStack", "ZStack", "NavigationStack"]) {
            self.node = node
        } else {
            return nil
        }
    }

}
