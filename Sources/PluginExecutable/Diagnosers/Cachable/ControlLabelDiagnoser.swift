import SwiftSyntax

final class ControlLabelDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        let controls = ["Button", "NavigationLink", "Link", "Menu"]
        
        for control in AnyCallCollector(controls, from: view.node).calls {
            
            for innerControl in AnyCallCollector(controls, from: control.additionalTrailingClosures).calls {
                warning("'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
        }
        
    }
    
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: FunctionCallExprSyntax) {
        appendInterpolation(value.calledExpression.trimmedDescription)
    }
}
