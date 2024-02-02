import SwiftSyntax

struct ControlLabelDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        let controls = ["Button", "NavigationLink", "Link", "Menu"]

        for control in ViewCallCollector(controls, from: view.node).calls {

            for innerControl in ViewCallCollector(controls, from: control.additionalTrailingClosures).calls {
                Diagnostics.emit(self, .warning, message: "'\(innerControl.calledExpression.trimmedDescription)' should not be placed inside '\(control.calledExpression.trimmedDescription)' label", node: innerControl, file: view.file)
            }
        }

    }

}
