import SwiftSyntax

struct NavigationPathWrapper {

    let views: [ViewDeclWrapper]
    
    init(_ views: [ViewDeclWrapper]) {
        self.views = views
    }

    init(views: [ViewDeclWrapper]) {

        var _views = [ViewDeclWrapper]()

        if let first = views.first {
            _views.append(first)
        }

    main: for i in views.indices.dropLast() {
        let current = views[i]
        let next = views[i+1]
        if current.node.trimmedDescription.contains("sheet") {
            for match in CallCollector(name: "sheet", current.node).matches {
                let children = ChildrenCollector(match.closure!).children.map({ ViewChildWrapper(node: $0) })
                if children.contains(where: { $0.name == next.name }) {
//                    print("'\(current.name)' has reference to '\(next.name)' on 'sheet'")
                    break main
                }
            }
            _views.append(next)
        } else {
            _views.append(next)
        }
    }

        self.views = _views
    }

//    var description: String {
//        return self.views.map(\.name).joined(separator: " -> ")
//    }

    var hasLoop: Bool {
        return Set(views).count < views.count
    }

}

extension NavigationPathWrapper {

    static func all(from view: ViewDeclWrapper, navigation: DeclReferenceExprSyntax, context: Context) -> [Self] {

        var paths = context._paths.values
            .flatMap { $0 }
            .filter { $0.contains(view) }
            .uniqued()
            .map { Array($0.reversed().drop(while: { $0 != view })) }
            .map {
                NavigationPathWrapper(views: $0)
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
        
        return paths
    }
    
}
