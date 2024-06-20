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
            
            if !modifiers.matches("accessibilityLabel", "accessibilityHidden").isEmpty {
                continue
            }

            
            if let label = image.parent(MultipleTrailingClosureElementSyntax.self, where: { $0.label.text == "label" }) {
                warning("Apply 'accessibilityLabel' modifier to provide a label for accessibility purpose", node: image, file: view.file)
            } else {
                warning("Apply 'accessibilityLabel' modifier to provide a label or 'accessibilityHidden(true)' to ignore it for accessibility purpose", node: image, file: view.file)
            }

        }

    }

}
