import SwiftSyntax

final class ImageDiagnoser: CachableDiagnoser {
   
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        for image in ViewCallCollector("Image", from: view.node).calls {
            
            print("IMAGE: \(image.calledExpression.trimmedDescription)")
            
            if !image.calledExpression.trimmedDescription.contains("Image") {
                print("warning: 😮")
            }

            if image.arguments.trimmedDescription.contains("systemName:") {
                if let symbol = image.arguments.first(where: { $0.label?.text == "systemName" })?.expression.as(StringLiteralExprSyntax.self)?.segments {
                    if !SFSymbols.all.contains(symbol.trimmedDescription) {
                        warning("There's no system symbol named '\(symbol)'", node: symbol, file: view.file)
                    }
                }
                continue
            }

            let modifiers = AppliedModifiersCollector(image)
            
//            for match in modifiers.matches {
//                warning(match.decl.trimmedDescription, node: image, file: view.file)
//            }

            for match in modifiers.matches("frame", "aspectRatio", "scaledToFit", "scaledToFill") {
                if let resizable = modifiers.matches("resizable").first, resizable.decl.position < match.decl.position {
                    continue
                }
                warning("Missing 'resizable' modifier", node: match.decl, offset: -1, file: view.file)
            }

        }

    }

}
