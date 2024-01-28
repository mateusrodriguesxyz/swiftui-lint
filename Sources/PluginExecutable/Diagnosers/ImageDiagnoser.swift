import SwiftSyntax

struct ImageDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            guard view.contains("Image") else { continue }

            for image in ViewCallCollector(["Image"], from: view.decl).calls {

                if image.arguments.isEmpty {
                    continue
                }

                if let symbol = image.arguments.first(where: { $0.label?.text == "systemName" })?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.all.contains(symbol.trimmedDescription) {
                        Diagnostics.emit(.warning, message: "There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                    continue
                }

                for frame in ModifiersFinder(modifiers: ["frame", "scaledToFit"])(image) {

                    if let resizable = ModifiersFinder(modifiers: ["resizable"])(image).first, resizable.node.position < frame.node.position {
                        continue
                    }

                    Diagnostics.emit(.warning, message: "Missing 'resizable' modifier", node: frame.node, offset: -1, file: view.file)
                }

            }

        }

    }

}
