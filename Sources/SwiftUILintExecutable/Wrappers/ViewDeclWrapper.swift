import SwiftSyntax
import Foundation

struct ViewDeclWrapper: Equatable, Hashable {

    static func == (lhs: ViewDeclWrapper, rhs: ViewDeclWrapper) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    let node: StructDeclSyntax

    let file: FileWrapper

    let name: String 

    var properties: [PropertyDeclWrapper] {
        return PropertyCollector(node).properties
    }

    var functions: [FunctionDeclWrapper] {
        return FunctionCollector(node).functions
    }

    var members: [any MemberWrapperProtocol] {
        return properties + functions
    }

    init(node: StructDeclSyntax, file: FileWrapper) {
        self.node = node
        self.name = node.name.text
        self.file = file
    }

}

extension ViewDeclWrapper {

    func property(named name: any StringProtocol) -> PropertyDeclWrapper? {
        return properties.first(where: { $0.name == name.replacingOccurrences(of: "$", with: "") })
    }

}

extension ViewDeclWrapper {
    
    func environmentObjectModifiers(_ context: Context) -> [EnvironmentObjectModifierWrapper] {
        
        ModifierCollector(modifiers: ["environment", "environmentObject"], node).matches.compactMap { match in
                        
            guard let content = match.content else {
                return nil
            }
            
            let targets = DestinationCollector(content, context: context).destinations

            if let call = match.expression?.expression.as(FunctionCallExprSyntax.self) {
                return EnvironmentObjectModifierWrapper(node: match.expression ?? match.node, property: "", type: call.calledExpression.trimmedDescription, targets: targets)
            }
            
            guard
                let object = match.expression?.trimmedDescription,
                let _property = property(named: object),
                let type = _property.type
            else {
                return nil
            }
            
            return EnvironmentObjectModifierWrapper(node: match.node, property: _property.name, type: type.description, targets: targets)
            
        }
        
    }
    
}


extension Array where Element == ViewDeclWrapper {

    var description: String {
        return self.map(\.name).reversed().joined(separator: " → ")
    }

    func distance(from start: ViewDeclWrapper, to end: FunctionCallExprSyntax) -> Int? {
        let loop = Array(self.reversed())
        guard let start = loop.firstIndex(where: { $0.name == start.name }) else { return nil }
        guard let end = loop.firstIndex(where: { $0.name == end.calledExpression.trimmedDescription }) else { return nil }
        return end - start
    }

    func pairs() -> some Sequence<(ViewDeclWrapper, ViewDeclWrapper)> {
        zip(reversed(), reversed().dropFirst())
    }
}

extension [[ViewDeclWrapper]] {

    func uniqued() -> [[ViewDeclWrapper]] {

        var result = [[ViewDeclWrapper]]()

        let sorted = self.sorted(using: KeyPathComparator(\.count, order: .reverse))

        for path in sorted where !result.contains(where: { $0.description.contains(path.description) }) {
            result.append(path)
        }

        return result

    }

}

extension [ViewDeclWrapper] {
    
    var hasLoop: Bool {
        return Set(self).count < self.count
    }

}
