import SwiftSyntax

struct StacksDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            func count(_ children: [ViewChildWrapper]) {

                let stacks = children.compactMap { StackDeclWrapper($0.node) }

                for stack in stacks {

                    let children = stack.children

//                    if children.count > 1 {
//
//                        var modifiers: [String: [Int]] = [:]
//
//                        for (index, child) in children.enumerated() {
//
//                            AllModifiersCollector(child.node).matches.forEach { match in
//                                modifiers[match.description] = (modifiers[match.description] ?? []) + [index]
//                            }
//                            
//                        }
//
//                        func repetitions(_ values: [Int]) -> [[Int]] {
//                            var repetitions: [[Int]] = []
//                            for index in values.indices {
//                                let value = values[index]
//                                if index == 0 {
//                                    repetitions.append([value])
//                                } else {
//                                    if value == values[index - 1] + 1 {
//                                        repetitions[repetitions.count - 1].append(value)
//                                    } else {
//                                        repetitions.append([value])
//                                    }
//                                }
//                            }
//                            return repetitions
//                        }
//
//                        modifiers.forEach { (modifier, indices) in
//                            let repetitions = repetitions(indices)
//
//                            for repetition in repetitions where repetition.count > 1 {
//                                let _children = repetition.map({ children[$0] })
//                                _children.forEach {
//                                    Diagnostics.emit(.warning, message: "⭐️ '\(modifier)' repeated in \(_children.formatted()); consider grouping them", node: $0.node, file: view.file)
//                                }
//                            }
//                        }
//
//                    }

                    if children.count == 0 {
                        if StatementCollector(stack.node).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(stack.name)' has no children; consider removing it", node: stack.node, file: view.file)
                        }
                    }

                    if children.count == 1 {
                        if !["HStack", "VStack", "ZStack"].contains(stack.name) {
                            continue
                        }
                        if let child = children.first, child.name.contains("ForEach") {
                            continue
                        }
                        if StatementCollector(stack.node).statement == nil {
                            Diagnostics.emit(.warning, message: "'\(stack.name)' has only one child; consider using '\(children.first!.name)' on its own", node: stack.node, file: view.file)
                        }
                    }

                    if stack.name == "NavigationStack", children.count > 1 {
                        Diagnostics.emit(.warning, message: "Use a container view to group \(children.formatted())", node: stack.node, file: view.file)
                    }

                    count(children)

                }
            }

            if let children = view.body?.elements {
                count(children)
            }

        }

    }

}
