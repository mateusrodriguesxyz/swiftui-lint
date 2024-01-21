import SwiftSyntax

struct FunctionDeclWrapper: MemberWrapperProtocol {

    var node: SyntaxProtocol { decl }

    let decl: FunctionDeclSyntax

    var attributes: Set<String> {
        return Set(decl.attributes.map(\.trimmedDescription))
    }

    var name: String {
        return decl.name.text
    }

    var type: String? {
        return decl.signature.returnClause?.type.trimmedDescription
    }

    var block: CodeBlockItemListSyntax? {
        return decl.body?.statements
    }

    init(decl: FunctionDeclSyntax) {
        self.decl = decl
    }

}
