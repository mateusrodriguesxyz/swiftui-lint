import SwiftSyntax
import Foundation

final class PathsBuilder {

    let name: String

    var paths: [[ViewDeclWrapper]] = []
    
    let _paths: [String : [[ViewDeclWrapper]]]

    init(view: ViewDeclWrapper, context: Context) {
        self.name = view.name
        self._paths = context.paths
        calls(of: view, context: context)
    }

    var loops: [[ViewDeclWrapper]] = []
    
    func matches(_ destination: ViewDeclWrapper, context: Context) -> [ViewDeclWrapper] {
        let all = context.views
        let destinations = context.destinations
        return all.filter {
            destinations[$0.name]!.contains(destination.name) || destinations[$0.name]!.contains("+\(destination.name)")
        }
    }

    func calls(of view: ViewDeclWrapper, context: Context, path: [ViewDeclWrapper] = []) {
        let path = path + [view]
        let matches = matches(view, context: context)
        if matches.isEmpty {
            paths.append(path)
        } else {
            for match in matches {
                if path.contains(where: { $0.name == match.name }) {
                    let loop = path + [match]
                    loops.append(loop)
                    paths.append(loop)
                } else {
//                    let additionalPaths = PathsBuilder(view: match, context: context).paths
//                    if !additionalPaths.contains(where: { $0.hasLoop }) {
//                        for additionalPath in additionalPaths {
//                            paths.append(path + additionalPath)
//                        }
//                    } else {
//                        calls(of: match, context: context, path: path)
//                    }
                    calls(of: match, context: context, path: path)
                }
            }
        }
    }

}


