import SwiftSyntax

final class ContainsNodeCollector: SyntaxAnyVisitor {

    let node: SyntaxProtocol

    var contains: Bool = false

    init(node: SyntaxProtocol, in closure: ClosureExprSyntax) {
        self.node = node
        super.init(viewMode: .sourceAccurate)
        walk(closure)
    }

    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if node.id == self.node.id {
            contains = true
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

}

final class ContainsCallCollector: SyntaxVisitor {

    let destination: String

    var contains: Bool = false

    init(destination: String, in closure: ClosureExprSyntax) {
        self.destination = destination
        super.init(viewMode: .sourceAccurate)
        walk(closure)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text == destination {
            contains = true
        }
        return .skipChildren
    }

}

final class CallStackCollector: SyntaxVisitor {

    let destination: String

    var matches: [ViewDeclWrapper] = []

    var current: ViewDeclWrapper?

    init(destination: String, views: [ViewDeclWrapper]) {
        self.destination = destination
        super.init(viewMode: .sourceAccurate)
        for view in views {
            if view.decl.trimmedDescription.contains(destination) {
                current = view
                walk(view.decl)
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

//final class NavigatonStackCallTrace {
//
//    var paths: [NavigationPathWrapper] = []
//
//    init(view: ViewDeclWrapper, context: Context) {
//        calls(in: view, context: context)
//    }
//
//    func calls(in view: ViewDeclWrapper, context: Context, path: [ViewDeclWrapper] = []) {
//        let path = path + [view]
//        let presenters = ViewPresenterCollector(view.decl).presenters
//        if presenters.isEmpty {
//            paths.append(NavigationPathWrapper(views: path))
//        } else {
//            for presenter in presenters {
//                if let _destination = presenter.destination?.calledExpression.trimmedDescription, let destination = context.view(named: _destination) {
//                    if path.contains(where: { $0.name == destination.name }) {
//                        let loop = path + [destination]
//                        paths.append(NavigationPathWrapper(views: loop))
//                    } else {
//                        calls(in: destination, context: context, path: path)
//                    }
//                }
//            }
//        }
//    }
//
//}
