import SwiftSyntax

public extension Equatable {
    func `is`(anyOf values: Self...) -> Bool {
        values.contains(self)
    }
}

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
                warning("'\(container.name)' has only one child; consider using '\(child.name)' on its own", node: container.node, file: view.file)
            }
            
            if children.count > 1, container.name == "NavigationStack" {
                warning("Use a container view to group \(children.formatted())", node: container.node, file: view.file)
            }
            
            if container.name.is(anyOf: "VStack", "HStack", "ZStack") {
                
                let defaultHorizontalAlignment = ["VStack": "HorizontalAlignment.center", "ZStack": "HorizontalAlignment.center"]
                let defaultVerticalAlignment = ["HStack": "VerticalAlignment.center", "ZStack": "VerticalAlignment.center"]
                                
                let containerAlignment = container.arguments?["alignment"].flatMap({ alignments($0.expression) })
                
                let containerHorizontalAlignment = containerAlignment?.horizontal ?? defaultHorizontalAlignment[container.name]
                
                let containerVerticalAlignment = containerAlignment?.vertical ?? defaultVerticalAlignment[container.name]
                                
                for child in container.children {
                    for match in AllAppliedModifiersCollector(child.node).matches("alignmentGuide") {
                        if let expression = match.arguments.first?.expression {
                            
                            let alignments = alignments(expression, isAlignmentGuide: true)
                                                        
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
                
                func alignments(_ expression: ExprSyntax, isAlignmentGuide: Bool = false) -> (horizontal: String?, vertical: String?) {
                    
                    guard let expression = expression.as(MemberAccessExprSyntax.self) else { return (nil, nil) }
                    
                    let declName = expression.declName.trimmedDescription
                    
                    let base = expression.base?.trimmedDescription
                    
                    var horizontal: String? = nil
                    var vertical: String? = nil
                    
                    switch base {
                        case "HorizontalAlignment":
                            horizontal = "HorizontalAlignment.\(declName)"
                        case "VerticalAlignment":
                            vertical = "VerticalAlignment.\(declName)"
                        default:
                            switch declName {
                                case "leading", "trailing":
                                    horizontal = "HorizontalAlignment.\(declName)"
                                    if !isAlignmentGuide {
                                        vertical = "VerticalAlignment.center"
                                    }
                                case "top", "bottom":
                                    if !isAlignmentGuide {
                                        horizontal = "HorizontalAlignment.center"
                                    }
                                    vertical = "VerticalAlignment.\(declName)"
                                case "topLeading":
                                    horizontal = "HorizontalAlignment.leading"
                                    vertical = "VerticalAlignment.top"
                                case "topTrailing":
                                    horizontal = "HorizontalAlignment.trailing"
                                    vertical = "VerticalAlignment.top"
                                case "bottomLeading":
                                    horizontal = "HorizontalAlignment.leading"
                                    vertical = "VerticalAlignment.bottom"
                                case "bottomTrailing":
                                    horizontal = "HorizontalAlignment.trailing"
                                    vertical = "VerticalAlignment.bottom"
                                default:
                                    break
                            }
                    }
                                        
                    return (horizontal, vertical)
                    
                }
            }
            
        }
    }
    
}
