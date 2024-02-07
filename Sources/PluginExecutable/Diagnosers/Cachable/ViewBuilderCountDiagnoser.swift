import SwiftSyntax

final class ViewBuilderCountDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Non-Grouped Views

        let members = view.members.compactMap(SomeViewWrapper.init)

        for member in members {
            if member.name == "body" || member.hasViewBuilderAttribute {
                let content = member.content
                if content.elements.count != 1 {
                    if member.hasViewBuilderAttribute {
                        let containers = ViewCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView", "ToolbarItemGroup"], from: view.node).calls.compactMap(ContainerDeclWrapper.init)
                        if containers.contains(where: { $0.closure?.trimmedDescription.contains(member.name) == true }) {
                            continue
                        }
                    }
                    warning("Use a container view to group \(content.formatted())", node: content.nodeSkippingAttributes, file: view.file)
                }
            }
        }

    }

}
