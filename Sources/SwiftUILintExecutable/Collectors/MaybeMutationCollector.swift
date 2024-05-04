import SwiftSyntax
import SwiftOperators

struct MutationWrapper {
    let node: SyntaxProtocol
    let target: String
}

final class MaybeMutationCollector: SyntaxVisitor {

    lazy var targets: [String] =  matches.map { $0.target.replacingOccurrences(of: "$", with: "") }
    lazy var bindings: [String] =  matches.filter({ $0.target.contains("$") }).map { $0.target.replacingOccurrences(of: "$", with: "") }
    
    private(set) var matches = [MutationWrapper]()

    package init(_ view: StructDeclSyntax) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: SequenceExprSyntax) -> SyntaxVisitorContinueKind {

        guard node.elements.count >= 3 else { return .skipChildren }
        let _operator = node.elements.dropFirst().first!
        if _operator.is(AssignmentExprSyntax.self) || _operator.is(BinaryOperatorExprSyntax.self) {
            if let binary = _operator.as(BinaryOperatorExprSyntax.self),  binary.operator.text.is(anyOf: "==", "!=", "??") {
                return .visitChildren
            }
            let lhs = node.elements.first!
            
            let target = {
                if let lhs = lhs.as(MemberAccessExprSyntax.self), lhs.base?.trimmedDescription == "self" {
                    lhs.declName.trimmedDescription
                } else {
                    lhs.trimmedDescription
                }
            }()
            
            matches.append(MutationWrapper(node: node, target: target))
        }

        return .visitChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let target = node.calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription {
            matches.append(MutationWrapper(node: node, target: target))
        }
        return .visitChildren
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text.contains("$") {
            matches.append(MutationWrapper(node: node, target: node.baseName.text))
        }
        return .visitChildren
    }

}
