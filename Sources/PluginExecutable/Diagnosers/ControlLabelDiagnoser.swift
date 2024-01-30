import SwiftSyntax

struct ControlLabelDiagnoser: Diagnoser {

    func diagnose(_ view: ViewDeclWrapper) {
        fatalError()
    }

    func run(context: Context) {

        let controls = ["Button", "NavigationLink", "Link", "Menu"]

        // MARK: Non-Grouped Views

        for view in context.views {

            guard view.contains(anyOf: controls) else { continue }

            for control in ViewCallCollector(controls, from: view.node).calls {

                for innerControl in ViewCallCollector(controls, from: control.additionalTrailingClosures).calls {
                    Diagnostics.emit(.warning, message: "'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
                }
            }

        }

    }

}
