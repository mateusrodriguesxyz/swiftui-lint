import SwiftSyntax

final class DeprecatedDiagnoser: Diagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {
                
        for view in context.views {
            
            let names = ["NavigationView", "foregroundColor"]
            
            for match in AnyCallCollector(names, from: view.node).matches {
                                
                if match.name == "NavigationView", context.target.iOS ?? 9999 >= 16.0 {
                    warning("'NavigationView' is deprecated; use 'NavigationStack' or 'NavigationSplitView' instead", node: match.node, file: view.file)
                }
                                
                if match.name == "foregroundColor", context.target.iOS ?? 9999 >= 16.0 {
                    warning("'foregroundColor' is deprecated; use 'foregroundStyle' instead", node: match.node, file: view.file)
                }
                
            }
            
            for property in view.properties {
                
                if property.node.trimmedDescription.contains("@Environment(\\.presentationMode)"), context.target.iOS ?? 9999 >= 15.0 {
                    warning("'presentationMode' is deprecated; use 'isPresented' or 'dismiss' instead", node: property.node, file: view.file)
                }
                
            }
            
        }
        
    }
    
}
