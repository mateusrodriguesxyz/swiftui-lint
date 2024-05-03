import SwiftSyntax

final class ScrollableDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Missing Scroll Content Background Hidden

        for scrollable in AnyCallCollector(["ScrollView", "List", "Form", "Table", "TextEditor"], from: view.node).calls {
            
            if scrollable.firstToken(viewMode: .sourceAccurate)?.text == "ScrollView", let content = scrollable.trailingClosure {
                let children = ChildrenCollector(content).children
                if children.count == 1, let child = children.first, child.firstToken(viewMode: .sourceAccurate)?.text == "HStack" {
                    if !scrollable.trimmedDescription.contains(".horizontal") {
                        warning("Use 'ScrollView(.horizontal)' to match 'HStack'", node: scrollable, file: view.file)
                    }
                }
            } else {
                let modifiers = AllAppliedModifiersCollector(scrollable)

                for match in modifiers.matches("background") {
                    if modifiers.contains("scrollContentBackground") {
                        continue
                    }
                    warning("Missing 'scrollContentBackground(.hidden)' modifier", node: match.decl, offset: -1, file: view.file)
                }
            }

        }

    }

}