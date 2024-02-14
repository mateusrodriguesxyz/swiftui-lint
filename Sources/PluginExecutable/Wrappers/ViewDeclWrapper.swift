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

    var name: String {
        node.name.text
    }

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
        self.file = file
    }

}

extension ViewDeclWrapper {

    func property(named name: any StringProtocol) -> PropertyDeclWrapper? {
        return properties.first(where: { $0.name == name })
    }

}

extension ViewDeclWrapper {
    
    func environmentObjectModifiers(_ context: Context) -> [EnvironmentObjectModifierWrapper] {
        
        ModifierCollector(modifier: "environmentObject", node).matches.compactMap { match in
            
            guard
                let object = match.expression?.trimmedDescription,
                let _property = property(named: object),
                let type = _property.type,
                let content = match.content
            else {
                return nil
            }

            let targets = DestinationCollector(content, context: context).destinations
            
            return EnvironmentObjectModifierWrapper(property: _property.name, type: type.description, targets: targets)
            
        }
        
    }
    
}


extension Array where Element == ViewDeclWrapper {

    var description: String {
        return self.map(\.name).reversed().joined(separator: " -> ")
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
    
//    func formatted() -> String {
//        return map(\.name).formatted(.list(type: .and).locale(.init(languageCode: .english)))
//    }

}
