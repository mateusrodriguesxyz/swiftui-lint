import SwiftSyntax

struct MissingDotModifierDiagnoser: Diagnoser {

    func diagnose(_ view: ViewDeclWrapper) {
        fatalError()
    }

    func run(context: Context) {

        for view in context.views {

            // MARK: Missing Modifier Leading Dot

            for call in BrokenModifierCallCollector(view.node).calls {
                Diagnostics.emit(.error, message: "Missing '\(call.baseName.text)' leading dot", node: call, file: view.file)
            }

        }

    }

}
