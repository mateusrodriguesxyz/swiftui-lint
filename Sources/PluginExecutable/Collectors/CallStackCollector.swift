import SwiftSyntax
import Foundation

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
    
    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(destination) {
            return .visitChildren
        } else {
            return .skipChildren
        }
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
//            print("warning: '\(view.name)' callers: \(matches.formatted())")
            for match in matches {
                if path.contains(where: { $0.name == match.name }) {
                    let loop = path + [match]
                    loops.append(loop)
                    paths.append(loop)
                } else {
                    
                    // EXC_BAD_ACCESS
                    let additionalPaths = context._paths[match.name]
    
                    if let additionalPaths, !additionalPaths.contains(where: { $0.hasLoop }) {
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


