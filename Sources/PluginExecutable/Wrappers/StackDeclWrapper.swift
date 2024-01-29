import SwiftSyntax

struct StackDeclWrapper {

    let node: SyntaxProtocol

    var name: String {
        return node.trimmedDescription.prefix(while: { $0 != "{" && $0 != "(" }).trimmingCharacters(in: .whitespaces)
    }

    var children: [ViewChildWrapper] {
        return ChildCollector(node).children.compactMap({ ViewChildWrapper($0) })
    }

    init?(_ node: SyntaxProtocol) {
        if node.trimmedDescription.contains(anyOf: ["VStack", "HStack", "ZStack", "NavigationStack", "ScrollView"]) {
            self.node = node
        } else {
            return nil
        }
    }

}
