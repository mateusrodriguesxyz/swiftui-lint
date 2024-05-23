import SwiftSyntax

final class ContainerDiagnoser: CachableDiagnoser {
   
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        for node in AnyCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView"], from: view.node).calls {
            
            guard let container = ContainerDeclWrapper(node) else { continue }
            
            let children = container.children
            
            if children.isEmpty {
                warning("'\(container.name)' has no children; consider removing it", node: container.node, file: view.file)
            }
                        
            if children.count == 1, container.name.is(anyOf: "HStack", "VStack", "ZStack", "Group"), let child = children.first {
                if child.name.contains("ForEach") {
                    continue
                }
                if child.name == "Group" {
                    continue
                }
                if container.closure?.statements.first?.item.is(ExpressionStmtSyntax.self) == true {
                    continue
                }
                warning("'\(container.name)' has only one child; consider using '\(child.name)' on its own", node: container.node, file: view.file)
            }
            
            if children.count > 1, container.name == "NavigationStack" {
                warning("Use a container view to group \(children.formatted())", node: container.node, file: view.file)
            }
            
            if container.name.is(anyOf: "VStack", "HStack", "ZStack") {
                
                let defaultHorizontalAlignment = ["VStack": "HorizontalAlignment.center", "ZStack": "HorizontalAlignment.center"]
                let defaultVerticalAlignment = ["HStack": "VerticalAlignment.center", "ZStack": "VerticalAlignment.center"]
                                
                let containerAlignment = container.arguments?["alignment"].flatMap({ alignment($0.expression) })
                
                let containerHorizontalAlignment = containerAlignment?.horizontal ?? defaultHorizontalAlignment[container.name]
                
                let containerVerticalAlignment = containerAlignment?.vertical ?? defaultVerticalAlignment[container.name]
                                
                for child in container.children {
                    for match in AllAppliedModifiersCollector(child.node).matches("alignmentGuide") {
                        if let expression = match.arguments.first?.expression {
                            
                            let alignments = alignment(expression, isAlignmentGuide: true)
                                                        
                            if container.name == "VStack" {
                                compare(alignments.horizontal ?? alignments.vertical, containerHorizontalAlignment)
                            }
                            
                            if container.name == "HStack" {
                                compare(alignments.vertical ?? alignments.horizontal, containerVerticalAlignment)
                            }
                            
                            if container.name == "ZStack" {
                                compare(alignments.horizontal, containerHorizontalAlignment)
                                compare(alignments.vertical, containerVerticalAlignment)
                            }
                            
                            func compare(_ alignmentGuide: String?, _ containerAlignment: String?) {
                                if let alignmentGuide, let containerAlignment, alignmentGuide != containerAlignment {
                                    warning("'\(alignmentGuide)' doesn't match '\(containerAlignment)' of '\(container.name)'", node: expression, file: view.file)
                                }
                            }
                        }
                    }
                }
                
                func alignment(_ expression: ExprSyntax, isAlignmentGuide: Bool = false) -> AlignmentWrapper {
                    AlignmentWrapper(expression, isAlignmentGuide: isAlignmentGuide)
                }
            }
            
        }
    }
    
}
