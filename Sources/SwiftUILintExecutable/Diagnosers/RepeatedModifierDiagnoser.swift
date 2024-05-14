import SwiftSyntax

final class RepeatedModifierDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    typealias RepeatedModifierIndex = (child: Int, modifier: SyntaxProtocol)
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        for node in AnyCallCollector(["VStack", "HStack", "ZStack", "NavigationStack", "Group", "ScrollView"], from: view.node).calls {
            
            guard let container = ContainerDeclWrapper(node) else { continue }
            
            run(container, file: view.file)
            
        }
        
    }

    func run(_ container: ContainerDeclWrapper, file: FileWrapper) {
        
        let children = container.children

        var modifiers: [String: [RepeatedModifierIndex]] = [:]

        for (index, child) in children.enumerated() {
                        
            AllAppliedModifiersCollector(child.node).matches("foregroundStyle", "font").forEach { match in
                let _index = (index, match.decl)
//                warning(match.description, node: match.decl, file: file)
                print(match.description)
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
        
        let numbers = ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣"]

        modifiers.forEach { (modifier, indices) in
            
            let repetitions = repetitions(indices.map(\.child))

            for repetition in repetitions where repetition.count > 1 {

//                let _children = repetition.map({ children[$0] })
                
                if repetition.count == children.count {
                    warning("'\(modifier)' repeated in all children; consider applying it to '\(container.name)' instead", node: container.node, file: file)
                    return
                }

                for index in repetition {

                    let _child = children[index]

                    let siblings = repetition.filter({ $0 != index })

                    let description = siblings.map({ numbers[$0] }).formatted(.list(type: .and))
                    
                    
                    
                    let siblings2 = siblings.map({ children[$0] })

                    
                    let description2 = (siblings.count == 1 ? "line " : "lines ") + siblings2.map({ "\(file.location(of: $0.node).line)" }).formatted(.list(type: .and))


                    let match = indices.first(where: { $0.child == index })!.modifier

//                    warning(numbers[index], node: _child.node, file: file)
//                    warning("'\(modifier)' repeated in \(siblings.count == 1 ? "sibling" : "siblings") \(description); consider grouping them", node: match, file: file)
                    warning("'\(modifier)' modifier repeated in \(siblings.count == 1 ? "sibling" : "siblings") (\(description2)); consider collecting them using 'Group' and applying modifier to the 'Group' instead", node: match, file: file)
//                    warning("'\(modifier)' modifier repeated in \(siblings.count == 1 ? "sibling" : "siblings"); consider collecting them using 'Group' and applying modifier to it", node: match, file: file)

                }
            }
        }

    }

}
