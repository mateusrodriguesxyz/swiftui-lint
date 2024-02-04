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

    var members: [MemberWrapperProtocol] {
        return properties + functions
    }

//    var body: ViewBuilderContentWrapper? {
//        if let body = node.memberBlock.members.first(where: { $0.trimmedDescription.contains("body")}) {
//            return body.decl.as(VariableDeclSyntax.self).map({ ViewBuilderContentWrapper($0) })
//        } else {
//            return nil
//        }
//    }

    init(decl: StructDeclSyntax, file: FileWrapper) {
        self.node = decl
        self.file = file
    }

}

extension ViewDeclWrapper {
    
    func contains(_ string: String) -> Bool {
        return node.trimmedDescription.contains(string)
    }

    func contains(anyOf strings: [String]) -> Bool {
        return node.trimmedDescription.contains(anyOf: strings)
    }

    func property(named name: any StringProtocol) -> PropertyDeclWrapper? {
        return properties.first(where: { $0.name == name })
    }

//    func property(of selection: SelectableContainerWrapper.Selection) -> PropertyDeclWrapper? {
//        return properties.first(where: { $0.name == selection.name })
//    }
//
//    func type(of selection: SelectableContainerWrapper.Selection) -> String? {
//        return property(of: selection)?.baseType
//    }

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
