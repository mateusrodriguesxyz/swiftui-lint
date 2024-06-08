import SwiftSyntax

final class SheetDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        for view in context.views {

            for match in AnyCallCollector(name: "sheet", view.node).matches {
                                
                guard let content = match.closure ?? match.arguments["content"]?.expression.as(ClosureExprSyntax.self) else {
                    continue
                }
                
                let children = ChildrenCollector(content).children.compactMap { ViewChildWrapper($0) }
                
                if children.count > 1 {
                    warning("Use a container view to group \(children.formatted())", node: match.closure!, file: view.file)
                }
                
                guard let isPresented = match.argument("isPresented") else {
                    continue
                }
                
                for child in children {
                    if let isPresentedReference = child.arguments?.first(where: { $0.expression.trimmedDescription == isPresented })?.label?.text {
                        if 
                            let view = context._views[child.name],
                            let property = view.property(named: isPresentedReference),
                            let mutation = MaybeMutationCollector(view.node).matches.first(where: { $0.target == property.name })
                        {
                            warning("Dismiss '\(view.name)' using environment 'DismissAction' instead", node: mutation.node, file: view.file)
                        }
                    }
                }

            }

        }

    }

}
