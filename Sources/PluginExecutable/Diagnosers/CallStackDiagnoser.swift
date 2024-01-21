import SwiftSyntax

struct CallStackDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            if let loop = context.loops(view).first {
                Diagnostics.emit(.error, message: "Infinite loop in call stack: \(loop.description)", node: view.decl, file: view.file)
            } else {
                for path in context.paths(to: view) {
                    if path.count > 1 {
                        Diagnostics.emit(.warning, message: path.description, node: view.decl, file: view.file)
                    }
                }
            }

        }

    }

}
