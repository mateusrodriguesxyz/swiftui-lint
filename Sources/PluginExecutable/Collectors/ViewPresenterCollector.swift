import SwiftSyntax
import RegexBuilder

final class ViewPresenterCollector {

    private(set) var presenters: [ViewPresenterWrapper] = []

    package init(_ node: SyntaxProtocol) {
        guard node.trimmedDescription.contains(anyOf: ["NavigationLink", "navigationDestination", "sheet", "popover", "fullScreenCover"]) else { return }
        presenters.append(contentsOf: CallsCollector(node).calls.compactMap({ ViewPresenterWrapper(node: $0) }))
        presenters.append(contentsOf: ReferencesCollector(node).references.compactMap({ ViewPresenterWrapper(node: $0) }))
    }

}

extension String {

    func contains(anyOf strings: some Sequence<String>) -> Bool {

//        let regex = Regex {
//            ChoiceOf {
//                try! Regex(strings.joined(separator: "|"))
//            }
//        }

        return strings.contains { contains($0) }
    }

}
