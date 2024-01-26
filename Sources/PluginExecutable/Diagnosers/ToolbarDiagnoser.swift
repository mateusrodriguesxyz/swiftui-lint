import SwiftSyntax

struct ToolbarDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            for match in CallCollector(name: "ToolbarItem", view.decl).matches {

                let content = ViewBuilderContentWrapper(match.closure!)

                if content.elements.count > 1 {
                    Diagnostics.emit(.warning, message: "Group \(content.elements.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
                }

                if let child = content.elements.first, let stack = StackDeclWrapper(child.node) {
                    Diagnostics.emit(.warning, message: "Group \(stack.children.formatted()) using 'ToolbarItemGroup' instead", node: match.node, file: view.file)
                }

            }

        }

    }

}
