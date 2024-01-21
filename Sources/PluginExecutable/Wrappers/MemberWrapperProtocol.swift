import SwiftSyntax

protocol MemberWrapperProtocol {

    var node: SyntaxProtocol { get }

    var attributes: Set<String> { get }

    var name: String { get }

    var type: String? { get }

    var block: CodeBlockItemListSyntax? { get }

}
