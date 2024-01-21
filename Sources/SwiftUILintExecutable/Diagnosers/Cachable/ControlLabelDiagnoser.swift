import SwiftSyntax

final class ControlLabelDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        let controls = ["Button", "NavigationLink", "Link", "Menu"]
        
        for control in AnyCallCollector(controls, from: view.node).calls {
            
            for innerControl in AnyCallCollector(controls, from: control.additionalTrailingClosures).calls {
                warning("'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
            
            if let label = control.additionalTrailingClosures.first {
                let children = ChildrenCollector(label).children
                if children.count == 1, let child = children.first, child.firstToken(viewMode: .sourceAccurate)?.text == "Image" {
                    if let image = AnyCallCollector("Image", from: child).calls.first {
                        warning("Use 'Button(_:systemImage:action:)' or 'Label(_:systemImage:)' to provide an accessibility label", node: image, file: view.file)
                    }
                }
            }
            
        }
        
    }
    
}
