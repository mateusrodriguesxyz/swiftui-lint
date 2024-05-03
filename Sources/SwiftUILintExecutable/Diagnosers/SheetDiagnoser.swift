import SwiftSyntax

final class SheetDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        for view in context.views {

            for match in AnyCallCollector(name: "sheet", view.node).matches {

                let children = ChildrenCollector(match.closure!).children.map({ ViewChildWrapper(node: $0) })

                if children.count > 1 {
                    warning("Use a container view to group \(children.formatted())", node: match.closure!, file: view.file)
                }
                if let isPresented = match.argument("isPresented") {

                    for child in children {
                        if let arguments = child.arguments {
                            if let isPresentedReference = arguments.first(where: { $0.expression.trimmedDescription == isPresented })?.label?.text {

                                if let view = context._views[child.name] {

                                    if let property = view.property(named: isPresentedReference) {

                                        if let mutation = MaybeMutationCollector(view.node).matches.first(where: { $0.target == property.name }) {
                                            warning("Dismiss '\(view.name)' using environment 'DismissAction' instead", node: mutation.node, file: view.file)
                                        }

                                    }

                                }
                            }

                        } 
                    }

                }

            }

        }

    }

}