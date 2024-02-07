import SwiftSyntax

struct ScrollableDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Missing Scroll Content Background Hidden

        for scrollable in ViewCallCollector(["List", "Form", "Table", "TextEditor"], from: view.node).calls {

            let modifiers = AppliedModifiersCollector(scrollable)

            for match in modifiers.matches("background") {
                if let scrollContentBackground = modifiers.matches("scrollContentBackground").first {
                    continue
                }
                Diagnostics.emit(self, .warning, message: "Missing 'scrollContentBackground(.hidden)' modifier", node: match.decl, offset: -1, file: view.file)
            }

        }

    }

}
