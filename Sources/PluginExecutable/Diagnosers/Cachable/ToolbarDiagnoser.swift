import SwiftSyntax

struct ToolbarDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        for match in CallCollector(name: "ToolbarItem", view.node).matches {

            let content = ViewBuilderContentWrapper(match.closure!)

            if content.elements.count > 1 {
                Diagnostics.emit(self, .warning, message: "Group \(content.elements.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
            }

            if let child = content.elements.first, child.name == "HStack", let stack = ContainerDeclWrapper(child.node) {
                Diagnostics.emit(self, .warning, message: "Group \(stack.children.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
            }

        }

    }

}
