import SwiftSyntax
import Foundation

final class NavigationDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        var destinations = Set<String>()

        for view in context.views {
            
//            if view.name == "CityView" {
//                for path in context.paths(to: view) {
//                    warning(path.description, node: view.node, file: view.file)
//                }
//            }
            
//            if view.name == "DetailColumn" {
//                if let destinations = context.destinations[view.name] {
//                    warning(destinations.description, node: view.node, file: view.file)
//                }
//            }
            
            for navigation in AnyCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], from: view.node).calls {
                
                let navigation = navigation.calledExpression.as(DeclReferenceExprSyntax.self)!
                
//                if let cache = context.cache?.navigations[view.file.location(of: navigation)] {
//                    if view.file.hasChanges == false, cache.hasChanges(context) == false {
//                        destinations = destinations.union(cache.members)
//                        continue
//                    }
//                }
                
                                                
                let paths = NavigationPathWrapper.all(from: view, navigation: navigation, context: context)
                
//                let cachable = NavigationCache(location: view.file.location(of: navigation), members: Set(paths.flatMap({ $0.views.map(\.name) })))
//                context.cache!.navigations[cachable.location] = cachable
                
                
                for path in paths {
                    
                    // MARK: Nested NavigationStack
                        
//                    if view.name == "ContentView" {
//                        warning(path.views.map(\.name).description + " (hasLoop = \(path.hasLoop))", node: navigation, file: view.file)
//                    }
                    
                    for child in path.views.dropFirst() {

                        if child.name == view.name {
                            continue
                        }

                        if destinations.insert(child.name).inserted {
                            let childNavigation = AnyCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], skipChildrenOf: "sheet", from: child.node).calls.first
                            
                            if let navigation = childNavigation {
                                warning("'\(child.name)' should not contain a NavigationStack", node: navigation, file: child.file)
                            }
                        }
                    }

                    // MARK: Navigation Loop

                    
                    if path.hasLoop, let loop = path.views.dropLast().last {

                        for presenter in ViewPresenterCollector(loop.node).matches where presenter.kind == .navigation {
                            if let destination = presenter.destination, let distance = path.views.dropLast().distance(from: loop, to: destination) {
                                if distance == 1 {
                                    warning("To navigate back to '\(destination)' use environment 'DismissAction' instead", node: presenter.node, file: loop.file)
                                } else {
                                    warning("To go back more than one level in the navigation stack, use NavigationStack 'init(path:root:)' to store the navigation state as a 'NavigationPath', pass it down the hierarchy and call 'removeLast(_:)'", node: presenter.node, file: loop.file)
                                }
                            }
                        }

                    }

                }
                
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
                
                for match in AllAppliedModifiersCollector(navigation).matches(modifiers) {
                    warning("Misplaced '\(match.name)' modifier; apply it to 'NavigationStack' content instead", node: match.decl, file: view.file)
                }

            }

        }
                                        
        for view in context.views {

            func diagnose(_ presenter: ViewPresenterWrapper) {
                if hasNavigationParent(presenter.node) {
                    return
                }
                warning("Missing 'NavigationStack'; '\(presenter.identifier)' only works within a navigation hierarchy", node: presenter.node, file: view.file)
            }

            // MARK: Missing NavigationStack

            if destinations.contains(view.name) {
                for match in AnyCallCollector(["sheet", "popover", "fullScreenCover"], from: view.node).matches {
                    guard let closure = match.closure else { continue }
                    for presenter in ViewPresenterCollector(closure).matches where presenter.kind == .navigation {
                        diagnose(presenter)
                    }
                }
                continue
            }
            
//            let modifiers = [
//                "navigationTitle",
//                "navigationBarTitleDisplayMode",
//                "navigationBarBackButtonHidden",
//                "navigationDestination",
//                "toolbar",
//                "toolbarRole",
//                "toolbarBackground",
//                "toolbarColorScheme"
//            ]
            
//            for match in AllAppliedModifiersCollector(view.node).matches(modifiers) {
//                
//                if match.name == "toolbar" {
//                    guard let content = match.closure else { continue }
//                    if context.target.macOS != nil {
//                        continue
//                    }
//                    for match in AnyCallCollector(["ToolbarItem", "ToolbarItemGroup"], from: content).matches {
//                        if match.arguments.trimmedDescription.contains("keyboard") {
//                            continue
//                        }
//                        warning("Missing NavigationStack; '\(match.name)' only works within a navigation hierarchy", node: match.node, file: view.file)
//                    }
//                } else {
//                    warning("Missing NavigationStack; '\(match.name)' only works within a navigation hierarchy", node: match.decl, file: view.file)
//                }
//            }

            for match in AnyCallCollector(["toolbar", "navigationTitle", "navigationBarTitleDisplayMode", "searchable", "pickerStyle"], from: view.node).matches {
                
                if hasNavigationParent(match.node) {
                    continue
                }
                                
                if context.target.macOS != nil {
                    continue
                }
                
                switch match.name {
                    case "toolbar":
                        guard let content = match.closure else { continue }
                    for match in AnyCallCollector(["ToolbarItem", "ToolbarItemGroup"], from: content).matches {
                            if match.arguments.trimmedDescription.contains("keyboard") {
                                continue
                            }
                            warning("Missing 'NavigationStack'; '\(match.name)' only works within a navigation hierarchy", node: match.node, file: view.file)
                        }
                    case "pickerStyle":
                        if let style = match.arguments.first?.trimmedDescription, style == ".navigationLink" {
                            warning("Missing 'NavigationStack'; '\(match.name)' only works within a navigation hierarchy", node: match.node, file: view.file)
                        }
                    default:
                        if diagnostics.contains(where: { $0.location == view.file.location(of: match.node) }) {
                            continue
                        }
                        warning("Missing 'NavigationStack'; '\(match.name)' only works within a navigation hierarchy", node: match.node, file: view.file)
                }
                
            }

            let presenters = ViewPresenterCollector(view.node).matches

            for presenter in presenters.filter({ $0.kind == .navigation }) {
                diagnose(presenter)
            }

        }

    }

}


func hasNavigationParent(_ node: SyntaxProtocol) -> Bool {
    
    let parent = node.parent(
        FunctionCallExprSyntax.self,
        where: {
            ["NavigationView", "NavigationStack", "NavigationSplitView"].contains($0.calledExpression.trimmedDescription)
        },
        stop: {
            $0?.as(CodeBlockItemSyntax.self)?.trimmedDescription.contains("sheet") == true
        }
    )
    
    guard let parent else {
        return false
    }
    
    // NavigationSplitView { 👍 } detail: { 👎 }
    if let split = NavigationSplitViewWrapper(parent) {
        if let sidebar = split.sidebar {
            return ContainsNodeVisitor(node: node, in: sidebar).contains
        } else {
            return false
        }
    } else {
        return true
    }
    
    
}