import SwiftSyntax

struct NavigationDiagnoser: Diagnoser {

    func run(context: Context) {

        var skip = Set<String>()

        for view in context.views {

//            ViewCallCollector(names: ["NavigationView", "NavigationStack",  "NavigationSplitView"], view.decl).calls

            for navigation in ViewCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], from: view.node).calls {

                let navigation = navigation.calledExpression.as(DeclReferenceExprSyntax.self)!

                // MARK: Deprecated NavigationView

                if navigation.baseName.text == "NavigationView" {
                    Diagnostics.emit(.warning, message: "'NavigationView' is deprecated; use NavigationStack or NavigationSplitView instead", node: navigation, file: view.file)
                }

                // MARK: Misplaced Navigation Modifier

                let modifiers = [
                    "navigationTitle",
                    "navigationBarTitleDisplayMode",
                    "navigationBarBackButtonHidden",
                    "navigationDestination",
                    "toolbar",
                    "toolbarRole",
                    "toolbarBackground",
                    "toolbarColorScheme"
                ]

                for match in ModifiersFinder(modifiers: modifiers)(navigation.parent?.parent) {
                    Diagnostics.emit(.warning, message: "Misplaced '\(match.modifier)' modifier; apply it to NavigationStack content instead", node: match.node, file: view.file)
                }

                var paths = context._paths.values
                    .flatMap { $0 }
                    .filter { $0.contains(view) }
                    .uniqued()
                    .map { Array($0.reversed().drop(while: { $0 != view })) }
                    .map { NavigationPathWrapper(views: $0) }

                if let split = NavigationSplitViewWrapper(navigation), let sidebar = split.sidebar {
                    paths.removeAll {
                        ContainsCallVisitor(destination: $0.views[1].name, in: sidebar).contains == false
                    }
                }

                for path in paths {

//                    Diagnostics.emit(.warning, message: path.description, node: navigation, file: view.file)

                    // MARK: Nested NavigationStack

                    for child in path.views.dropFirst() {

                        if child.name == view.name {
                            continue
                        }

                        skip.insert(child.name)

                        let navigation1 = ViewCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], skipChildrenOf: "sheet", from: child.node).calls.first

                        if let navigation = navigation1 {
                            Diagnostics.emit(.warning, message: "'\(child.name)' should not contain a NavigationStack", node: navigation, file: child.file)
                        }
                    }

                    // MARK: Navigation Loop

                    if path.hasLoop, let loop = path.views.dropLast().last {

                        for presenter in ViewPresenterCollector(loop.node).presenters where presenter.kind == .navigation {
                            if let destination = presenter.destination, let distance = path.views.dropLast().distance(from: loop, to: destination) {
                                if distance == 1 {
                                    Diagnostics.emit(.warning, message: "To navigate back to '\(destination.calledExpression.trimmedDescription)' use environment 'DismissAction' instead", node: presenter.node, file: view.file)
                                } else {
                                    Diagnostics.emit(.warning, message: "To go back more than one level in the navigation stack, use NavigationStack 'init(path:root:)' to store the navigation state as a 'NavigationPath', pass it down the hierarchy and call 'removeLast(_:)'", node: presenter.node, file: view.file)
                                }
                            }
                        }

                    }

                }

            }

        }

        for view in context.views {

            // MARK: Missing NavigationStack

            if skip.contains(view.name) {
                continue
            }

            for match in ModifierCollector(modifier: "toolbar", view.node).matches {
                if  let _ = match.decl.parent(FunctionCallExprSyntax.self, where: { ["NavigationView", "NavigationStack"].contains($0.calledExpression.trimmedDescription) }) {
                    continue
                }
                Diagnostics.emit(.warning, message: "Missing NavigationStack; '\(match.name)' only works within a navigation hierarchy", node: match.decl, file: view.file)
            }

//            if !view.contains(anyOf: ["NavigationLink", "navigationDestination"]) {
//                continue
//            }

            let presenters = ViewPresenterCollector(view.node).presenters

            if presenters.isEmpty {
                continue
            }

//            var isWithinNavigationHierarchy = false
//            
//        hierarchy: for path in context.paths(to: view) where path.count > 1 {
//            
//            let path = Array(path.reversed())
//            
//            if let index = path.firstIndex(where: { NavigationViewOrStackFinder()($0.decl) != nil }) {
//                
//                let view = path[index]
//                
//                for navigation in NavigationViewOrStackFinder().search(view.decl) {
//                    
//                    if index < (path.count - 2) {
//                        
//                        let next = path[index + 1]
//                        
//                        if let split = NavigationSplitViewWrapper(navigation) {
//                            
//                            if let sidebar = split.sidebar {
//                                if ContainsCallCollector(destination: next.name, in: sidebar).contains {
//                                    print("'isWithinNavigationHierarchy' setted")
//                                    isWithinNavigationHierarchy = true
//                                    break hierarchy
//                                }
//                            }
//                        }
//                        
//                        if let stack = NavigationStackWrapper(navigation) {
//                            
//                            if let content = stack.content {
//                                if ContainsCallCollector(destination: next.name, in: content).contains {
//                                    print("'isWithinNavigationHierarchy' setted")
//                                    isWithinNavigationHierarchy = true
//                                    break hierarchy
//                                }
//                            }
//                            
//                        }
//                    }
//                    
//                }
//                
//            }
//        }
//            
//            if isWithinNavigationHierarchy {
//                continue
//            }

            for presenter in presenters.filter({ $0.kind == .navigation }) {
                if let _ = presenter.node.parent(FunctionCallExprSyntax.self, where: { ["NavigationView", "NavigationStack"].contains($0.calledExpression.trimmedDescription) }) {
                    continue
                }
                if let node = presenter.node.parent(FunctionCallExprSyntax.self, where: { $0.calledExpression.trimmedDescription == "NavigationSplitView" }) {
                    let split = NavigationSplitViewWrapper(node)
                    if let sidebar = split.sidebar {
                        if ContainsNodeVisitor(node: presenter.node, in: sidebar).contains {
                            continue
                        }
                    }
                }

                Diagnostics.emit(.warning, message: "Missing NavigationStack; '\(presenter.identifier)' only works within a navigation hierarchy", node: presenter.node, file: view.file)

            }

        }

    }

}

extension [String] {

    static var navigation: [String] {
        [
            "navigationTitle",
            "navigationBarTitleDisplayMode",
            "navigationBarBackButtonHidden",
            "navigationDestination",
            "toolbar",
            "toolbarRole",
            "toolbarBackground",
            "toolbarColorScheme"
        ]
    }

}
