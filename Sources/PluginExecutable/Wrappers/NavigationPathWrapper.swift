import SwiftSyntax

struct NavigationPathWrapper {

    let views: [ViewDeclWrapper]

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

    static func all(from view: ViewDeclWrapper, in context: Context) -> [Self] {
        context._paths.values
            .flatMap { $0 }
            .filter { $0.contains(view) }
            .uniqued()
            .map { Array($0.reversed().drop(while: { $0 != view })) }
            .map {
                NavigationPathWrapper(views: $0)
            }
    }
}
