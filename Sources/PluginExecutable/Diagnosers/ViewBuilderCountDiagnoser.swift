import SwiftSyntax

struct ViewBuilderCountDiagnoser: Diagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Non-Grouped Views

        let members = view.members.compactMap(SomeViewWrapper.init)

        for member in members {
            if member.name == "body" || member.hasViewBuilderAttribute {
                let content = member.content
                if content.elements.count != 1 {
                    if view.node.trimmedDescription.matches(of: Regex{"\(member.name)"}).count > 1 {
                        continue
                    }
                    Diagnostics.emit(.warning, message: "Use a container view to group \(content.formatted())", node: content.nodeSkippingAttributes, file: view.file)
                }
            }
        }

    }

}
