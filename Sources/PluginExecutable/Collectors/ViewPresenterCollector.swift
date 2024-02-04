import SwiftSyntax
import RegexBuilder

final class NavigationLinkAndDestinationCollector: SyntaxVisitor {

    private(set) var matches = [ViewPresenterWrapper]()

    private var skipNextClosure = false

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        guard node.trimmedDescription.contains(anyOf: ["NavigationLink", "navigationDestination"]) else { return }
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if let presenter = ViewPresenterWrapper(node: node) {
            matches.append(presenter)
            if case .modal = presenter.kind {
                skipNextClosure = true
            }
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let presenter = ViewPresenterWrapper(node: node) {
            matches.append(presenter)
        }
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if skipNextClosure {
            skipNextClosure = false
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}


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
