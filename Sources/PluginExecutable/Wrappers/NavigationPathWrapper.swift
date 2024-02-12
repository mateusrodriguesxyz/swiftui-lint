import SwiftSyntax

struct NavigationPathWrapper {
    
    let views: [ViewDeclWrapper]
    
    init(_ views: [ViewDeclWrapper]) {
        self.views = views
    }
    
    var hasLoop: Bool {
        return Set(views).count < views.count
    }
    
    var description: String {
        return views.map(\.name).joined(separator: " → ")
    }
    
}

extension NavigationPathWrapper {
    
    static func build(_ views: [ViewDeclWrapper]) -> Self {
        
        var _views = [ViewDeclWrapper]()
        
        if let first = views.first {
            _views.append(first)
        }
        
    filter:
        for i in views.indices.dropLast() {
            let current = views[i]
            let next = views[i+1]
            if current.node.trimmedDescription.contains("sheet") {
                for match in CallCollector(name: "sheet", current.node).matches {
                    let children = ChildrenCollector(match.closure!).children.map({ ViewChildWrapper(node: $0) })
                    if children.contains(where: { $0.name == next.name }) {
                        break filter
                    }
                }
                _views.append(next)
            } else {
                _views.append(next)
            }
        }
        
        return NavigationPathWrapper(_views)
        
    }
    
}

extension NavigationPathWrapper {
    
    static func all(from view: ViewDeclWrapper, navigation: DeclReferenceExprSyntax, context: Context) -> [Self] {
        
        //        if let cached = context.cache?.paths[view.file.location(of: navigation)]?.build(context) {
        //            return cached
        //        }
        
        var paths = context._paths.values
            .flatMap { $0 }
            .filter { $0.contains(view) }
            .uniqued()
            .map { Array($0.reversed().drop(while: { $0 != view })) }
            .map {
                NavigationPathWrapper.build($0)
            }
        
        if let split = NavigationSplitViewWrapper(navigation), let sidebar = split.sidebar {
            paths.removeAll { path in
                if path.views.count > 1 {
                    return _ContainsNodeVisitor(named: path.views[1].name, in: sidebar).contains == false
                } else {
                    return false
                }
            }
        }
        
        paths.removeAll { path in
            if let first = path.views.dropFirst().first {
                return ViewCallCollector([first.name], skipChildrenOf: "sheet", from: navigation.parent(CodeBlockItemSyntax.self)!).calls.first == nil
            } else {
                return false
            }
        }
        
        //        let codable = NavigationPathCodable(navigation, paths: paths, file: view.file)
        //        context.cache?.paths[codable.location] = codable
        
        return paths
    }
    
}

//extension NavigationPathWrapper {
//    
//    func hasChanges() -> Bool {
//        views.allSatisfy {
//            $0.file.hasChanges
//        }
//    }
//    
//}
//
//struct NavigationPathCodable: Codable {
//    let location: SourceLocation
//    let paths: [[String]]
//}
//
//extension NavigationPathCodable {
//    
//    init(_ navigation: SyntaxProtocol, paths: [NavigationPathWrapper], file: FileWrapper) {
//        self.init(location: file.location(of: navigation), paths: paths.map({ $0.views.map(\.name) }))
//    }
//    
//    func build(_ context: Context) -> [NavigationPathWrapper] {
//        paths.map { path in
//            NavigationPathWrapper(path.compactMap({ context._views[$0] }))
//        }
//    }
//    
//}
