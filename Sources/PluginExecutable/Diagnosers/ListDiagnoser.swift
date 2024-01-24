import SwiftSyntax

struct ListDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            for container in ViewCallCollector(["List", "Picker"], from: view.decl).calls.map(SelectableContainerWrapper.init) {

                if container.name == "List" {

                    let modifiers = [
                        "listRowInsets",
                        "listRowSeparator",
                        "listRowSeparatorTint",
                        "listRowBackground",
                        "listItemTint"
                    ]

                    for match in ModifiersFinder(modifiers: modifiers)(container.node.parent, file: view.file) {
                        Diagnostics.emit(.warning, message: "Misplaced '\(match.modifier)' modifier; apply it to List rows instead", node: match.node, file: view.file)
                    }

                }

                guard let selection = container.selection(from: view) else { break }

                if selection.type.isSet, container.name == "Picker"  {
                    Diagnostics.emit(.warning, message: "'Picker' doesn't support multiple selections", node: selection.node, file: view.file)
                    continue
                }

                let selectionType = container.name == "List" ? selection.type.baseType : selection.type.description

                for child in container.children {

                    if !child.trimmedDescription.contains("ForEach") {

                        if let tag = child.tag() {
                            if let type = tag.type(context), type.description != selectionType {
                                let value = tag.node.expression.trimmedDescription.replacingOccurrences(of: #"""#, with: "")
                                Diagnostics.emit(.warning, message: "tag value '\(value)' type '\(type.description)' doesn't match '\(selection.name)' type '\(selectionType)'", node: tag.node, file: view.file)
                            }
                        } else {
                            if container.name == "Picker" {
                                Diagnostics.emit(.warning, message: "Apply 'tag' modifier with '\(selectionType)' value to match '\(selection.name)' type", node: child, file: view.file)
                            }
                        }

                        continue

                    }
                    

                    guard let forEach = ForEachWrapper(node: child) else { continue }

                    guard let data = forEach.data else { continue }


                    switch data {
                        case .range:
                            diagnose("Int", isRange: true)
                        case .property(let name):

                            guard let property = PropertyCollector(view.decl).properties.first(where: { $0.name == name }) else { break }

                            guard let dataElementType = property.baseType else {
                                break
                            }

                            if let customType = context.structs.first(where: { $0.name.text == dataElementType }) {
                                if let id = PropertyCollector(customType).properties.first(where: { $0.name == (forEach.id ?? "id") }), id.type != selectionType {
                                    if forEach.id != nil {
                                        Diagnostics.emit(.warning, message: "ForEach' data element '\(customType.name.text)' member '\(id.name)' type '\(id.type!)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
                                    } else {
                                        Diagnostics.emit(.warning, message: "ForEach' data element '\(customType.name.text)' id type '\(id.type!)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
                                    }
                                }

                            } else {
                                diagnose(dataElementType)
                            }

                        case .array(let dataElementType):
                            diagnose(dataElementType)
                    }

                    func diagnose(_ dataElementType: String, isRange: Bool = false) {
                        if isRange || forEach.id == "self" {
                            if dataElementType != selectionType {
                                if let tag = forEach.content!.tag() {
                                    if let type = tag.type(context), type.description != selectionType {
                                        let value = tag.node.expression.trimmedDescription.replacingOccurrences(of: #"""#, with: "")
                                        Diagnostics.emit(.warning, message: "tag value '\(value)' type '\(type.description)' doesn't match '\(selection.name)' type '\(selectionType)'", node: tag.node, file: view.file)
                                    }
//                                    Diagnostics.emit(.warning, message: "tag = \(tag.node) (TODO)", node: tag.node, file: view.file)
                                } else {
                                    if container.name == "Picker", dataElementType == selection.type.baseType, let content = forEach.content {
                                        Diagnostics.emit(.warning, message: "Apply 'tag' modifier with explicit Optional<\(selection.type.baseType)> value to match '\(selection.name)' type '\(selectionType)'", node: content.lastToken(viewMode: .sourceAccurate)!, file: view.file)
                                    } else {
                                        Diagnostics.emit(.warning, message: "'ForEach' data element type '\(dataElementType)' doesn't match '\(selection.name)' type '\(selectionType)'", node: forEach.node, file: view.file)
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
