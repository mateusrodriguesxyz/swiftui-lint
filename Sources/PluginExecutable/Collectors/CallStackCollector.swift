import SwiftSyntax
import Foundation

//final class CallStackCollector: SyntaxVisitor {
//
//    let destination: String
//
//    var matches: [ViewDeclWrapper] = []
//
//    var current: ViewDeclWrapper?
//
//    init(destination: String, views: [ViewDeclWrapper]) {
//        self.destination = destination
//        super.init(viewMode: .sourceAccurate)
//        for view in views {
//            if view.node.trimmedDescription.contains(destination) {
//                current = view
//                walk(view.node)
//            }
//        }
//    }
//
//    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
//        if node.baseName.text == destination {
//            if let current {
//                matches.append(current)
//            }
//        }
//        return .skipChildren
//    }
//    
//    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
//        if node.trimmedDescription.contains(destination) {
//            return .visitChildren
//        } else {
//            return .skipChildren
//        }
//    }
//
//}

final class CallStackTrace {

    let name: String

    var paths: [[ViewDeclWrapper]] = []
    
    let _paths: [String : [[ViewDeclWrapper]]]

    init(view: ViewDeclWrapper, context: Context) {
        self.name = view.name
        self._paths = context._paths
        calls(of: view, context: context)
    }

    var loops: [[ViewDeclWrapper]] = []
    
    func matches(_ destination: ViewDeclWrapper, context: Context) -> [ViewDeclWrapper] {
        let all = context.views
        let destinations = context.destinations
        return all.filter {
            destinations[$0.name]!.contains(destination.name) || destinations[$0.name]!.contains("+\(destination.name)")
        }
//        return CallStackCollector(destination: destination.name, views: context.views).matches
    }

    func calls(of view: ViewDeclWrapper, context: Context, path: [ViewDeclWrapper] = []) {
        let path = path + [view]
        let matches = matches(view, context: context)
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
                    let additionalPaths = _paths[match.name]
    
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


