import SwiftSyntax
import Foundation

final class ViewBuilderCountDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Non-Grouped Views

        let members = view.members.compactMap(SomeViewWrapper.init)

        for member in members where (member.name == "body" || member.hasViewBuilderAttribute) {
            
            let content = member.content
            
            if let block = content.node.descendant(CodeBlockItemListSyntax.self) {
                for property in PropertyCollector(block).properties where property.attributes.contains("@State") {
                    warning("Variable '\(property.name)' should be declared as a stored property of '\(view.name)'", node: property.node, file: view.file)
                }
            }
            
            if content.elements.count != 1 {
                if member.hasViewBuilderAttribute {
                    let containers = AnyCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView", "ToolbarItemGroup"], from: view.node).calls.compactMap(ContainerDeclWrapper.init)
                    if containers.contains(where: { $0.closure?.trimmedDescription.contains(member.name) == true }) {
                        continue
                    }
                }
                let numbers = ["1️⃣", "2️⃣", "3️⃣"]
                
//                    let _content = content.elements.indices.map({ numbers[$0] }).formatted(.list(type: .and).locale(Locale(identifier: "en_UK")))
//
                if let block = BlockCollector(content.node).block {
                    warning("Use a container view to group \(content.formatted())", node: block, file: view.file)
                }
                
                
                
//                    for (index, child) in content.elements.enumerated() {
//                        note("\(index)", node: child.node, file: view.file)
//                    }
            }
        }

    }

}
