import SwiftSyntax

final class MissingDotModifierDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Missing Modifier Leading Dot

        for call in BrokenModifierCallCollector(view.node).calls {
            error("Missing '\(call.baseName.text)' leading dot", node: call, file: view.file)
        }

    }

}
