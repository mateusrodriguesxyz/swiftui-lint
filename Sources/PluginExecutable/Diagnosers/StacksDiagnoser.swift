import SwiftSyntax

struct StacksDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            func modifiers(of node: SyntaxProtocol) {
                let modifiers = AllModifiersCollector(node).matches
//                Diagnostics.emit(.warning, message: "modifiers: \(modifiers.count)", node: node, file: view.file)
//                for modifier in modifiers {
//                    Diagnostics.emit(.warning, message: modifier.description, node: modifier.decl, file: view.file)
//                }
            }

            func count(_ children: [ViewChildWrapper]) {

                let stacks = children.compactMap { StackDeclWrapper($0.node) }

                for stack in stacks {

                    modifiers(of: stack.node)

                    let children = stack.children

//                    Diagnostics.emit(.warning, message: "children: \(children.count)", node: stack.node, file: view.file)

                    if children.count == 0 {
                        if StatementCollector(stack.node).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(stack.name)' has no children; consider removing it", node: stack.node, file: view.file)
                        }
                    }

                    if children.count == 1 {
                        if ["HStack", "VStack", "ZStack"].contains(stack.name), let child = children.first, !child.name.contains("ForEach") {
                            if let closure = stack.closure, StatementCollector(closure).statement == nil {
                                Diagnostics.emit(.warning, message: "'\(stack.name)' has only one child; consider using '\(child.name)' on its own", node: stack.node, file: view.file)
                            }
                        }
                    }

                    if stack.name == "NavigationStack", children.count > 1 {
                        Diagnostics.emit(.warning, message: "Use a container view to group \(children.formatted())", node: stack.node, file: view.file)
                    }

                    count(children)

//                    continue

                    if children.count > 0 {

                        for child in children {

                            modifiers(of: child.node)

                        }

                        continue

                        typealias RepeatedModifierIndex = (child: Int, modifier: SyntaxProtocol)

                        var modifiers: [String: [RepeatedModifierIndex]] = [:]

                        for (index, child) in children.enumerated() {

                            AllModifiersCollector(child.node).matches.forEach { match in
                                if match.description.contains(anyOf: ["resizable", "scaledToFit"]) {
                                    return
                                }
                                let _index = (index, match.decl)
                                modifiers[match.description] = (modifiers[match.description] ?? []) + [_index]
                            }

                        }

                        func repetitions(_ values: [Int]) -> [[Int]] {
                            var repetitions: [[Int]] = []
                            for index in values.indices {
                                let value = values[index]
                                if index == 0 {
                                    repetitions.append([value])
                                } else {
                                    if value == values[index - 1] + 1 {
                                        repetitions[repetitions.count - 1].append(value)
                                    } else {
                                        repetitions.append([value])
                                    }
                                }
                            }
                            return repetitions
                        }

                        modifiers.forEach { (modifier, indices) in
                            let repetitions = repetitions(indices.map(\.child))

                            for repetition in repetitions where repetition.count > 1 {

                                let _children = repetition.map({ children[$0] })

                                for index in repetition {

                                    let _child = children[index]

                                    let siblings = repetition.filter({ $0 != index }).map({ "'\($0)'" })

                                    let description = siblings.formatted(.list(type: .and))

                                    let match = indices.first(where: { $0.child == index })!.modifier

                                    Diagnostics.emit(.warning, message: "'\(index)'", node: _child.node, file: view.file)
                                    Diagnostics.emit(.warning, message: "'\(modifier)' repeated in \(siblings.count == 1 ? "sibling" : "siblings") \(description); consider grouping them", node: match, file: view.file)
                                }
                            }
                        }

                    }

                }
            }

            if let children = view.body?.elements {
                count(children)
            }

        }

    }

}
