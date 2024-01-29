import SwiftSyntax

struct ImageDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            for image in ViewCallCollector("Image", from: view.node).calls {

                if let symbol = image.arguments.first(where: { $0.label?.text == "systemName" })?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.all.contains(symbol.trimmedDescription) {
                        Diagnostics.emit(.warning, message: "There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                    continue
                }

                let modifiers = AllModifiersCollector(image)

                for match in modifiers.matches("frame", "aspectRatio", "scaledToFit", "scaledToFill") {
                    if let resizable = modifiers.matches("resizable").first, resizable.decl.position < match.decl.position {
                        continue
                    }
                    Diagnostics.emit(.warning, message: "Missing 'resizable' modifier", node: match.decl, offset: -1, file: view.file)
                }

//                for frame in ModifiersFinder(modifiers: ["frame", "scaledToFit"])(image) {
//
//                    if let resizable = ModifiersFinder(modifiers: ["resizable"])(image).first, resizable.node.position < frame.node.position {
//                        continue
//                    }
//
//                    Diagnostics.emit(.warning, message: "Missing 'resizable' modifier", node: frame.node, offset: -1, file: view.file)
//                }

            }

        }

    }

}
