import SwiftSyntax


final class CallStackCollector: SyntaxVisitor {

    let destination: String

    var matches: [ViewDeclWrapper] = []

    var current: ViewDeclWrapper?

    init(destination: String, views: [ViewDeclWrapper]) {
        self.destination = destination
        super.init(viewMode: .sourceAccurate)
        for view in views {
            if view.node.trimmedDescription.contains(destination) {
                current = view
                walk(view.node)
            }
        }
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text == destination {
            if let current {
                matches.append(current)
            }
        }
        return .skipChildren
    }

}

final class CallStackTrace {

    let name: String

    var paths: [[ViewDeclWrapper]] = []

    init(view: ViewDeclWrapper, context: Context) {
        self.name = view.name
        calls(of: view, context: context)
    }

    var loops: [[ViewDeclWrapper]] = []

    func calls(of view: ViewDeclWrapper, context: Context, path: [ViewDeclWrapper] = []) {
        let path = path + [view]
        let matches = CallStackCollector(destination: view.name, views: context.views).matches
        if matches.isEmpty {
            paths.append(path)
        } else {
            for match in matches {
                if path.contains(where: { $0.name == match.name }) {
                    let loop = path + [match]
                    loops.append(loop)
                    paths.append(loop)
                } else {
                    if let additionalPaths = context._paths[match.name] {
                        for additionalPath in additionalPaths {
                            paths.append(path + additionalPath)
                        }
                    } else {
                        calls(of: match, context: context, path: path)
                    }
//                    calls(of: match, context: context, path: path)
                }
            }
        }
    }

}
