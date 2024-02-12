import SwiftSyntax

final class ScrollableDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Missing Scroll Content Background Hidden

        for scrollable in AnyCallCollector(["List", "Form", "Table", "TextEditor"], from: view.node).calls {

            let modifiers = AppliedModifiersCollector(scrollable)

            for match in modifiers.matches("background") {
                if let _ = modifiers.matches("scrollContentBackground").first {
                    continue
                }
                warning("Missing 'scrollContentBackground(.hidden)' modifier", node: match.decl, offset: -1, file: view.file)
            }

        }

    }

}
