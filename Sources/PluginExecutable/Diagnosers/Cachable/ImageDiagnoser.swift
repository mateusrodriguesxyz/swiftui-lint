import SwiftSyntax

final class ImageDiagnoser: CachableDiagnoser {
   
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        for image in AnyCallCollector("Image", from: view.node).calls {
                   
            if image.trimmedDescription.contains("systemName") {
                if let symbol = image.arguments.first(where: { $0.label?.text == "systemName" })?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.contains(symbol) {
                        warning("There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                }
                continue
            }

            let modifiers = AllAppliedModifiersCollector(image)

            for match in modifiers.matches("frame", "aspectRatio", "scaledToFit", "scaledToFill") {
                if let resizable = modifiers.matches("resizable").first, resizable.decl.position < match.decl.position {
                    continue
                }
                warning("Missing 'resizable' modifier", node: match.decl, offset: -1, file: view.file)
            }

        }

    }

}
