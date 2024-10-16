import SwiftSyntax

final class ToolbarDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        for match in AnyCallCollector(name: "ToolbarItem", view.node).matches {

            let content = ViewBuilderContentWrapper(match.closure!)

            if content.elements.count > 1 {
                warning("Group \(content.elements.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
            }

            if let child = content.elements.first, child.name == "HStack", let stack = ContainerDeclWrapper(child.node) {
                warning("Group \(stack.children.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
            }

        }

    }

}
