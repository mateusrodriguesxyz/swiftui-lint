import SwiftSyntax

struct MissingDotModifierDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            // MARK: Missing Modifier Leading Dot

            for decl in BrokenModifierCallCollector(view.decl).decls {
                Diagnostics.emit(.error, message: "Missing '\(decl.baseName.text)' leading dot", node: decl, file: view.file)
            }

        }

    }

}
