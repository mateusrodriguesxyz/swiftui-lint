import SwiftSyntax

struct ImageDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        for image in ViewCallCollector("Image", from: view.node).calls {

            if image.arguments.trimmedDescription.contains("systemName:") {
                if let symbol = image.arguments.first(where: { $0.label?.text == "systemName" })?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.all.contains(symbol.trimmedDescription) {
                        Diagnostics.emit(self, .warning, message: "There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                }
                continue
            }

            let modifiers = AllModifiersCollector(image)

            for match in modifiers.matches("frame", "aspectRatio", "scaledToFit", "scaledToFill") {
                if let resizable = modifiers.matches("resizable").first, resizable.decl.position < match.decl.position {
                    continue
                }
                Diagnostics.emit(self, .warning, message: "Missing 'resizable' modifier", node: match.decl, offset: -1, file: view.file)
            }

        }

    }

}
