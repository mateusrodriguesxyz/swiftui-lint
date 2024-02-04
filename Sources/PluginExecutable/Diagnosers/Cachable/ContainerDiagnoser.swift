import SwiftSyntax

struct ContainerDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {
        for node in ViewCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView"], from: view.node).calls {

            let container = ContainerDeclWrapper(node)!

            let children = container.children

//            for child in children {
//                for modifier in AllModifiersCollector(child.node).matches {
//                    let name = modifier.decl
//                    let arguments = modifier.arguments.trimmedDescription
//                    let closure = modifier.closure?.trimmedDescription.replacingOccurrences(of: "\n", with: "") ?? ""
//                    Diagnostics.emit(.warning, message: "name = \(name) ; arguments = (\(arguments)) ; closure = \(closure)", node: modifier.decl, file: view.file)
//                }
//            }

            if children.count == 0 {
//                if StatementCollector(container.node).statement == nil {
                    Diagnostics.emit(self, .warning, message: "'\(container.name)' has no children; consider removing it", node: container.node, file: view.file)
//                }
            }

            if children.count == 1 {
                if ["HStack", "VStack", "ZStack", "Group"].contains(container.name), let child = children.first {
                    if child.name.contains("ForEach") {
                        continue
                    }
//                    if let closure = container.closure, StatementCollector(closure).statement == nil {
                        Diagnostics.emit(self, .warning, message: "'\(container.name)' has only one child; consider using '\(child.name)' on its own", node: container.node, file: view.file)
//                    }
                }
            }

            if container.name == "NavigationStack", children.count > 1 {
                Diagnostics.emit(self, .warning, message: "Use a container view to group \(children.formatted())", node: container.node, file: view.file)
            }

        }
    }

}
