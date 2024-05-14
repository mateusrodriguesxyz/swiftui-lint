import SwiftSyntax

final class FrameDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        for node in AnyCallCollector(["VStack", "HStack"], from: view.node).calls {
            
            guard let container = ContainerDeclWrapper(node) else { continue }

            if container.children.count == 2 {
                let first = container.children.first!
                let last = container.children.last!
                if first.name == "Spacer" {
                    if container.name == "HStack" {
                        warning("Consider applying 'frame(maxWidth: .infinity, alignment: .trailing)' modifier to '\(last.name)' instead", node: node, file: view.file)
                    }
                    if container.name == "VStack" {
                        warning("Consider applying 'frame(maxHeight: .infinity, alignment: .bottom)' modifier to '\(last.name)' instead", node: node, file: view.file)
                    }
                }
                if last.name == "Spacer" {
                    if container.name == "HStack" {
                        warning("Consider applying 'frame(maxWidth: .infinity, alignment: .leading)' modifier to '\(first.name)' instead", node: node, file: view.file)
                    }
                    if container.name == "VStack" {
                        warning("Consider applying 'frame(maxHeight: .infinity, alignment: .top)' modifier to '\(first.name)' instead", node: node, file: view.file)
                    }
                }
            }
            
        }
        
        if view.node.trimmedDescription.contains(".infinity") {
            for match in AnyCallCollector(["frame"], from: view.node).matches {
                for argument in match.arguments.filter({ $0.expression.trimmedDescription == ".infinity" }) {
                    if argument.label?.trimmedDescription == "width" {
                        warning("Use 'maxWidth' instead", node: argument, file: view.file)
                    }
                    if argument.label?.trimmedDescription == "height" {
                        warning("Use 'maxHeight' instead", node: argument, file: view.file)
                    }
                }
            }
        }
        
    }
    
}
