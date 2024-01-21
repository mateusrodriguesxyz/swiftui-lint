import SwiftSyntax

struct FunctionDeclWrapper: MemberWrapperProtocol {

    let node: FunctionDeclSyntax

    var attributes: Set<String> {
        return Set(node.attributes.map(\.trimmedDescription))
    }

    var name: String {
        return node.name.text
    }

    var type: String? {
        return node.signature.returnClause?.type.trimmedDescription
    }

    var block: CodeBlockItemListSyntax? {
        return node.body?.statements
    }

    init(_ node: FunctionDeclSyntax) {
        self.node = node
    }

}
