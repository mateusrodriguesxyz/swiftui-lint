import SwiftSyntax

struct ContainerDeclWrapper {

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
        self.node = node
//        if node.trimmedDescription.contains(anyOf: ["VStack", "HStack", "ZStack", "NavigationStack", "ScrollView", "Group", "ToolbarItemGroup"]) {
//            self.node = node
//        } else {
//            return nil
//        }
    }

}
