import SwiftSyntax

struct _RepeatedModifierDiagnoser {

    typealias RepeatedModifierIndex = (child: Int, modifier: SyntaxProtocol)

    func run(_ children: [ViewChildWrapper], file: FileWrapper) {

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

                    Diagnostics.emit(.warning, message: "'\(index)'", node: _child.node, file: file)
                    Diagnostics.emit(.warning, message: "'\(modifier)' repeated in \(siblings.count == 1 ? "sibling" : "siblings") \(description); consider grouping them", node: match, file: file)
                }
            }
        }

    }

}
