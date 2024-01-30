import SwiftSyntax


struct ContainerDiagnoser: Diagnoser {
    
    func run(context: Context) {

        for view in context.views {

            for node in ViewCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView"], from: view.node).calls {

                guard let container = StackDeclWrapper(node) else { continue }
                
                let children = container.children

                if children.count == 0 {
                    if StatementCollector(container.node).statement == nil {
                        Diagnostics.emit(.warning, message: "'\(container.name)' has no children; consider removing it", node: container.node, file: view.file)
                    }
                }

                if children.count == 1 {
                    if ["HStack", "VStack", "ZStack", "Group"].contains(container.name), let child = children.first, !child.name.contains("ForEach") {
                        if let closure = container.closure, StatementCollector(closure).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(container.name)' has only one child; consider using '\(child.name)' on its own", node: container.node, file: view.file)
                        }
                    }
                }

                if container.name == "NavigationStack", children.count > 1 {
                    Diagnostics.emit(.warning, message: "Use a container view to group \(children.formatted())", node: container.node, file: view.file)
                }

            }

        }

    }

}
