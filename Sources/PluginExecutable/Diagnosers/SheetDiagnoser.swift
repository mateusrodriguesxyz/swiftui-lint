import SwiftSyntax

struct SheetDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            for match in CallCollector(name: "sheet", view.decl).matches {

                let children = ChildrenCollector(match.closure!).children.map({ ViewChildWrapper(node: $0) })

                if children.count > 1 {
                    Diagnostics.emit(.warning, message: "Use a container view to group \(children.formatted())", node: match.closure!, file: view.file)
                }
                if let isPresented = match.argument("isPresented") {

                    for child in children {
                        if let arguments = child.arguments {
                            if let isPresentedReference = arguments.first(where: { $0.expression.trimmedDescription == isPresented })?.label?.text {

                                if let view = context.view(named: child.name) {

                                    if let property = view.property(named: isPresentedReference) {

//                                        Diagnostics.emit(.warning, message: "Reference to sheet 'isPresented'", node: property.decl, file: view.file)

                                        if let mutation = MaybeMutationCollector(view.decl).matches.first(where: { $0.target == property.name }) {
                                            Diagnostics.emit(.warning, message: "Dismiss '\(view.name)' using environment 'DismissAction' instead", node: mutation.node, file: view.file)
                                        }

                                    }

                                }

//                                Diagnostics.emit(.warning, message: "isPresentedReference = \(isPresentedReference)", node: arguments, file: view.file)
                            }

                        } else {
                            Diagnostics.emit(.error, message: "🫠", node: child.node, file: view.file)
                        }
                    }

                }

            }

        }

    }

}
