import SwiftSyntax

protocol MemberWrapperProtocol {
    
    associatedtype Node: SyntaxProtocol

    var node: Node { get }

    var attributes: Set<String> { get }

    var name: String { get }

    var type: String? { get }

    var block: CodeBlockItemListSyntax? { get }

}
