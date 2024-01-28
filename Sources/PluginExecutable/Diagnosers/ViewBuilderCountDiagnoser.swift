import SwiftSyntax

struct ViewBuilderCountDiagnoser: Diagnoser {

    func run(context: Context) {

        // MARK: Non-Grouped Views

        for view in context.views {

            let members = view.members.compactMap(SomeViewWrapper.init)

            for member in members {
                if member.name == "body" || member.hasViewBuilderAttribute {
                    let content = member.content
                    if content.elements.count != 1 {
                        if view.decl.trimmedDescription.matches(of: Regex{"\(member.name)"}).count > 1 {
                            continue
                        }
                        Diagnostics.emit(.warning, message: "Use a container view to group \(content.formatted())", node: content.nodeSkippingAttributes, file: view.file)
//                        content.elements.enumerated().forEach { (index, child) in
//                            Diagnostics.emit(.warning, message: "@\(index)", node: child.node, file: view.file)
//                        }
                    }
                }
            }

        }

    }

}
