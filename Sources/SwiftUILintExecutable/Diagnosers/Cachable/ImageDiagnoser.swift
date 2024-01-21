import SwiftSyntax

final class ImageDiagnoser: CachableDiagnoser {
   
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        for image in AnyCallCollector("Image", from: view.node).calls {
                   
            if image.trimmedDescription.contains("systemName") {
                if let symbol = image.arguments["systemName"]?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.contains(symbol) {
                        warning("There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                }
                continue
            }

            let modifiers = AllAppliedModifiersCollector(image)

            for match in modifiers.matches("frame", "aspectRatio", "scaledToFit", "scaledToFill") {
                if modifiers.contains("resizable") {
                    continue
                }
                warning("Missing 'resizable' modifier", node: match.decl, offset: -1, file: view.file)
            }
            
            if image.arguments.trimmedDescription.contains(anyOf: "decorative", "label")  {
                continue
            }

            warning("Use 'Image(_:label:)' to provide an accessibility label or 'Image(decorative:)' to ignore it for accessibility purposes", node: image, file: view.file)

        }

    }

}
