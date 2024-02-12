import SwiftSyntax

final class ContainerDiagnoser: CachableDiagnoser {
   
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        for node in AnyCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView"], from: view.node).calls {
            
            let container = ContainerDeclWrapper(node)!
            
            let children = container.children
            
            if children.count == 0 {
                warning("'\(container.name)' has no children; consider removing it", node: container.node, file: view.file)
            }
            
            if children.count == 1 {
                if ["HStack", "VStack", "ZStack", "Group"].contains(container.name), let child = children.first {
                    if child.name.contains("ForEach") {
                        continue
                    }
                    warning("'\(container.name)' has only one child; consider using '\(child.name)' on its own", node: container.node, file: view.file)
                }
            }
            
            if container.name == "NavigationStack", children.count > 1 {
                warning("Use a container view to group \(children.formatted())", node: container.node, file: view.file)
            }
            
        }
    }
    
}
