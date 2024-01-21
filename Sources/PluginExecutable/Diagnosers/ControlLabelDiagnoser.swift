import SwiftSyntax

struct ControlLabelDiagnoser: Diagnoser {

    func run(context: Context) {

        let controls = ["Button", "NavigationLink", "Link", "Menu"]

        // MARK: Non-Grouped Views

        for view in context.views {

            guard view.contains(anyOf: controls) else { continue }

            for control in ViewCallCollector(controls, from: view.decl).calls {

                for innerControl in ViewCallCollector(controls, from: control.additionalTrailingClosures).calls {
                    Diagnostics.emit(.warning, message: "'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
                }
            }

        }

    }

}

extension String.StringInterpolation {

    mutating func appendInterpolation(_ value: FunctionCallExprSyntax) {
        appendInterpolation(value.calledExpression.trimmedDescription)
    }
    
}
