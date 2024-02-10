import SwiftSyntax
import Foundation

final class NavigationDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        var skip = Set<SyntaxIdentifier>()

        for view in context.views {

            for navigation in ViewCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], from: view.node).calls {

                let navigation = navigation.calledExpression.as(DeclReferenceExprSyntax.self)!

                // MARK: Deprecated NavigationView

                if context.target.iOS ?? 9999 >= 16.0 {
                    if navigation.baseName.text == "NavigationView" {
                        warning("'NavigationView' is deprecated; use NavigationStack or NavigationSplitView instead", node: navigation, file: view.file)
                    }
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
                
                for match in AppliedModifiersCollector(navigation).matches(modifiers) {
                    warning("Misplaced '\(match.decl.baseName.text)' modifier; apply it to NavigationStack content instead", node: match.decl, file: view.file)                }

//                for match in ModifiersFinder(modifiers: modifiers)(navigation.parent?.parent) {
//                    warning("Misplaced '\(match.modifier)' modifier; apply it to NavigationStack content instead", node: match.node, file: view.file)
//                }

                var paths = NavigationPathWrapper.all(from: view, in: context)

                if let split = NavigationSplitViewWrapper(navigation), let sidebar = split.sidebar {
                    paths.removeAll { path in
                        if path.views.count > 1 {
                            return _ContainsNodeVisitor(named: path.views[1].name, in: sidebar).contains == false
//                            return ContainsCallVisitor(destination: path.views[1].name, in: sidebar).contains == false
                        } else {
                            return false
                        }
                    }
                }


                for child in ChildrenCollector(navigation.parent(CodeBlockItemSyntax.self)!).children.compactMap({ ViewChildWrapper($0) }) {
                    paths.removeAll {
                        $0.views.dropFirst().first?.name != child.name
                    }
                }

                for path in paths {

//                    warning(path.description, node: navigation, file: view.file)

                    // MARK: Nested NavigationStack

                    for child in path.views.dropFirst() {

                        if child.name == view.name {
                            continue
                        }

                        skip.insert(child.node.id)

                        let navigation1 = ViewCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], skipChildrenOf: "sheet", from: child.node).calls.first

                        if let navigation = navigation1 {
                            warning("'\(child.name)' should not contain a NavigationStack", node: navigation, file: child.file)
                        }
                    }

                    // MARK: Navigation Loop

                    if path.hasLoop, let loop = path.views.dropLast().last {

                        for presenter in _ViewPresenterCollector(loop.node).matches where presenter.kind == .navigation {
                            if let destination = presenter.destination, let distance = path.views.dropLast().distance(from: loop, to: destination) {
                                if distance == 1 {
                                    warning("To navigate back to '\(destination.calledExpression.trimmedDescription)' use environment 'DismissAction' instead", node: presenter.node, file: view.file)
                                } else {
                                    warning("To go back more than one level in the navigation stack, use NavigationStack 'init(path:root:)' to store the navigation state as a 'NavigationPath', pass it down the hierarchy and call 'removeLast(_:)'", node: presenter.node, file: view.file)
                                }
                            }
                        }

                    }

                }

            }

        }

        for view in context.views {

            func hasNavigationParent(_ node: SyntaxProtocol) -> Bool {
                node.parent(
                    FunctionCallExprSyntax.self,
                    where: {
                        ["NavigationView", "NavigationStack"].contains($0.calledExpression.trimmedDescription)
                    },
                    stop: {
                        $0?.as(CodeBlockItemSyntax.self)?.trimmedDescription.contains("sheet") == true
                    }
                ) != nil
            }

            func diagnose(_ presenter: ViewPresenterWrapper) {
                if hasNavigationParent(presenter.node) {
                    return
                }
                if let node = presenter.node.parent(FunctionCallExprSyntax.self, where: { $0.calledExpression.trimmedDescription == "NavigationSplitView" }) {
                    let split = NavigationSplitViewWrapper(node)
                    if let sidebar = split.sidebar {
                        if _ContainsNodeVisitor(node: presenter.node, in: sidebar).contains {
                            return
                        }
//                        if ContainsNodeVisitor(node: presenter.node, in: sidebar).contains {
//                            return
//                        }
                    }
                }

                warning("Missing NavigationStack; '\(presenter.identifier)' only works within a navigation hierarchy", node: presenter.node, file: view.file)
            }

            // MARK: Missing NavigationStack

            if skip.contains(view.node.id) {
                
                for sheet in SheetContentCollector(view.node).matches {
                    for presenter in _ViewPresenterCollector(sheet).matches where presenter.kind == .navigation {
                        diagnose(presenter)
                    }
                }
                continue
            }

            for match in ModifierCollector(modifiers: ["toolbar", "navigationBarTitleDisplayMode"], view.node).matches {
                
                if hasNavigationParent(match.decl) {
                    continue
                }
                                
                if context.target.macOS != nil {
                    continue
                }
                
                guard let content = match.content else { continue }
                
                for match in CallCollector(name: "ToolbarItem", content).matches {
                    if match.arguments.trimmedDescription.contains("keyboard") {
                        continue
                    }
                    warning("Missing NavigationStack; '\(match.name)' only works within a navigation hierarchy", node: match.node, file: view.file)
                }
                
            }

            let presenters = _ViewPresenterCollector(view.node).matches

            for presenter in presenters.filter({ $0.kind == .navigation }) {
                diagnose(presenter)
            }

        }

    }

}
