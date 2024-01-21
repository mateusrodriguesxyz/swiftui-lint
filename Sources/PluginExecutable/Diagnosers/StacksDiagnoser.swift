import SwiftSyntax

struct StacksDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            func count(_ children: [ViewChildWrapper]) {

                let stacks = children.compactMap { StackDeclWrapper($0.node) }

                for stack in stacks {

                    let children = stack.children

                    if children.count == 0 {
                        if StatementCollector(stack.node).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(stack.name)' has no children; consider removing it", node: stack.node, file: view.file)
                        }
                    }

                    if children.count == 1 {
                        if !["HStack", "VStack", "ZStack"].contains(stack.name) {
                            continue
                        }
                        if let child = children.first, child.name.contains("ForEach") {
                            continue
                        }
                        if StatementCollector(stack.node).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(stack.name)' has only one child; consider using '\(children.first!.name)' on its own", node: stack.node, file: view.file)
                        }
                    }

                    if stack.name == "NavigationStack", children.count > 1 {
                        Diagnostics.emit(.warning, message: "Use a container view to group \(children.formatted())", node: stack.node, file: view.file)
                    }

                    count(children)

                }
            }

            if let children = view.body?.elements {
                count(children)
            }

        }

    }

}
