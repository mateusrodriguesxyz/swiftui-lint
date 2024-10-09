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
        
        modifiers.forEach { (modifier, indices) in
            
            let repetitions = repetitions(indices.map(\.child))

            for repetition in repetitions where repetition.count > 1 {
                
                if repetition.count == children.count {
                    warning("'\(modifier)' repeated in all children; consider applying it to '\(container.name)' instead", node: container.node, file: file)
                    return
                }

                for index in repetition {

                    let siblings = repetition.filter({ $0 != index }).map({ children[$0] })

                    let description = (siblings.count == 1 ? "line " : "lines ") + siblings.map({ "\(file.location(of: $0.node).line)" }).formatted(.list(type: .and))

                    let match = indices.first(where: { $0.child == index })!.modifier

                    warning("'\(modifier)' modifier repeated in \(siblings.count == 1 ? "sibling" : "siblings") (\(description)); consider collecting them using 'Group' and applying modifier to the 'Group' instead", node: match, file: file)

                }
            }
        }

    }

}
