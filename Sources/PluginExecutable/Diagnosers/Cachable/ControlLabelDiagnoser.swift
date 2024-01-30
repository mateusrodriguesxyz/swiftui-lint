import SwiftSyntax

struct ControlLabelDiagnoser: Diagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        let controls = ["Button", "NavigationLink", "Link", "Menu"]

        guard view.contains(anyOf: controls) else { return }

        for control in ViewCallCollector(controls, from: view.node).calls {

            for innerControl in ViewCallCollector(controls, from: control.additionalTrailingClosures).calls {
                Diagnostics.emit(.warning, message: "'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
        }

    }

}
