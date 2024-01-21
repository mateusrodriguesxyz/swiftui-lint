import SwiftSyntax

struct ViewBuilderCountDiagnoser: Diagnoser {

    func run(context: Context) {

        // MARK: Non-Grouped Views

        for view in context.views {

            for member in view.members {
                if let member = SomeViewWrapper(member), member.name == "body" || member.hasViewBuilderAttribute {
                    let content = member.content
                    if content.elements.count != 1 {
                        Diagnostics.emit(.warning, message: "Use a container view to group \(content.formatted())", node: content.nodeSkippingAttributes, file: view.file)
                    }
                }
            }

        }

    }

}
