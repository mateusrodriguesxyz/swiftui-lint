import SwiftSyntax
import Foundation

struct ViewBuilderContentWrapper {

    let node: SyntaxProtocol

    var elements: [ViewChildWrapper]

//    var start: SyntaxProtocol {
//        if let variable = node.as(VariableDeclSyntax.self) {
//            return variable.bindingSpecifier
//        }
//        if let function = node.as(FunctionDeclSyntax.self) {
//            return function.attributes.nextToken(viewMode: .fixedUp)!
//        }
//        return node
//    }

    var nodeSkippingAttributes: SyntaxProtocol {
        elements.first!.node.previousToken(viewMode: .sourceAccurate)!
//        if let token = elements.first?.node.previousToken(viewMode: .sourceAccurate) {
//            return token
//        } else {
//            return node
//        }
    }

//    init(_ decl: VariableDeclSyntax) {
//        self.node = decl
//        self.elements = decl.bindings.first?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self)?.map({ ViewChildWrapper(node: $0.item) }) ?? []
//    }

    init(_ member: MemberWrapperProtocol) {
        self.node = member.node
        self.elements = member.block?.compactMap {
            if $0.item.is(VariableDeclSyntax.self) {
                return nil
            } else {
                return ViewChildWrapper(node: $0.item)
            }
        } ?? []
    }

//    init(_ node: MultipleTrailingClosureElementListSyntax ) {
//        self.node = node
//        self.elements = node.first?.closure.statements.map({ ViewChildWrapper(node: $0.item) }) ?? []
//    }

    init(_ node: ClosureExprSyntax ) {
        self.node = node
        self.elements = node.statements.map({ ViewChildWrapper(node: $0.item) }) 
    }

    func formatted() -> String {
        return elements.formatted()
    }
}

extension [ViewChildWrapper] {

    func formatted() -> String {
        map {
            "'\($0.name)'"
        }
        .formatted(.list(type: .and).locale(Locale(identifier: "en_UK")))
    }

}
