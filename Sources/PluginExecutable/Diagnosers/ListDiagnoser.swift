import SwiftSyntax

final class ListDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        for view in context.views {

            for container in ViewCallCollector(["List", "Picker"], from: view.node).calls.map(SelectableContainerWrapper.init) {

                if container.name == "List" {

                    let modifiers = [
                        "listRowInsets",
                        "listRowSeparator",
                        "listRowSeparatorTint",
                        "listRowBackground",
                        "listItemTint"
                    ]

                    for match in ModifiersFinder(modifiers: modifiers)(container.node.parent, file: view.file) {
                        warning("Misplaced '\(match.modifier)' modifier; apply it to List rows instead", node: match.node, file: view.file)
                    }

                }

                guard let selection = container.selection(from: view, context: context) else { break }

                if selection.type.isSet, container.name == "Picker" {
                    warning("'Picker' doesn't support multiple selections", node: selection.node, file: view.file)
                    continue
                }

                let selectionType = container.name == "List" ? selection.type.baseType : selection.type.description

                var forEachs = [ForEachWrapper]()

                for child in container.children {

                    if !child.trimmedDescription.contains("ForEach") {

                        if let tag = child.tag() {
                            if let type = tag.type(context), type.description != selectionType {
                                warning("tag value '\(tag.value)' type '\(type.description)' doesn't match '\(selection.name)' type '\(selectionType)'", node: tag.node, file: view.file)
                            }
                        } else {
                            if container.name == "Picker" {
                                warning("Apply 'tag' modifier with '\(selectionType)' value to match '\(selection.name)' type", node: child, file: view.file)
                            }
                        }

                        continue

                    }

                    if let forEach = ForEachWrapper(node: child) {
                        forEachs.append(forEach)

                    }

//                    guard let forEach = ForEachWrapper(node: child) else { continue }
//
//                    forEachs.append(forEach)

                }

                if container.name == "List", forEachs.isEmpty {
                    if let forEach = ForEachWrapper(node: container.node.parent(CodeBlockItemSyntax.self)!) {
                        forEachs.append(forEach)
                    }
                }

                for forEach in forEachs {

                    guard let data = forEach.data else { continue }

                    switch data {
                        case .range:
                            diagnose("Int", isRange: true)
                        case .property(let name):

                            guard let property = PropertyCollector(view.node).properties.first(where: { $0.name == name }) else { break }

                            guard let dataElementType = property.baseType else {
                                print("error: No Base Type for '\(property.name)' of '\(view.name)'")
                                break
                            }

                            if let customType = context.structs.first(where: { $0.name.text == dataElementType }) {
                                if let id = PropertyCollector(customType).properties.first(where: { $0.name == (forEach.id ?? "id") }), id.type != selectionType {
                                    if forEach.id != nil {
                                        warning("'ForEach' data element '\(customType.name.text)' member '\(id.name)' type '\(id.type!)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
                                    } else {
                                        warning("'ForEach' data element '\(customType.name.text)' id type '\(id.type!)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
                                    }
                                }

                            } else {
                                diagnose(dataElementType)
                            }

                        case .array(let dataElementType):
                            diagnose(dataElementType)
                    }

                    func diagnose(_ dataElementType: String, isRange: Bool = false) {
                        guard isRange || forEach.id == "self" else {
                            return
                        }
                        if dataElementType != selectionType {
                            if let tag = forEach.content!.tag() {
                                if let type = tag.type(context), type.description != selectionType {
                                    warning("tag value '\(tag.value)' type '\(type.description)' doesn't match '\(selection.name)' type '\(selectionType)'", node: tag.node, file: view.file)
                                }
                            } else {
                                if container.name == "Picker", dataElementType == selection.type.baseType, let content = forEach.content {
                                    warning("Apply 'tag' modifier with explicit Optional<\(selection.type.baseType)> value to match '\(selection.name)' type '\(selectionType)'", node: content.lastToken(viewMode: .sourceAccurate)!, file: view.file)
                                } else {
                                    warning("'ForEach' data element type '\(dataElementType)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
                                }
                            }
                        }
                    }
                }

            }

        }

    }

}
