import SwiftSyntax

final class ControlLabelDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
                
        for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: view.node).calls {
            
            for innerControl in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: control.additionalTrailingClosures).calls {
                warning("'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
            
            if let label = control.additionalTrailingClosures.first {
                let children = ChildrenCollector(label).children
                if children.count == 1, let child = children.first, child.firstToken(viewMode: .sourceAccurate)?.text == "Image" {
                    if let image = AnyCallCollector("Image", from: child).calls.first {
                        if control.calledExpression.trimmedDescription == "Button" {
                            warning("Use 'Button(_:systemImage:action:)' or 'Label(_:systemImage:)' to provide an accessibility label", node: image, file: view.file)
                        } else {
                            warning("Use 'Label(_:systemImage:)' to provide an accessibility label", node: image, file: view.file)
                        }
                    }
                }
            }
            
        }
        
        for control in AnyCallCollector(["Stepper", "Toggle", "Picker", "DatePicker", "MultiDatePicker", "ColorPicker"], from: view.node).calls {
            
            if let label = control.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments, label.trimmedDescription.isEmpty {
                warning("Consider providing a non-empty label for accessibility purpose and using 'labelsHidden' modifier to omit it in the user interface", node: label, file: view.file)

            }
            
        }
        
    }
    
}
