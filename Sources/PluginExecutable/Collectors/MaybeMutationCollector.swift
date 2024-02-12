import SwiftSyntax
import SwiftOperators

struct MutationWrapper {
    let node: SyntaxProtocol
    let target: String
}

final class MaybeMutationCollector: SyntaxVisitor {

    lazy var targets: [String] =  matches.map(\.target)

    private(set) var matches = [MutationWrapper]()

    package init(_ view: StructDeclSyntax) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: SequenceExprSyntax) -> SyntaxVisitorContinueKind {

        guard node.elements.count >= 3 else { return .skipChildren }
        let _operator = node.elements.dropFirst().first!
        if _operator.is(AssignmentExprSyntax.self) || _operator.is(BinaryOperatorExprSyntax.self) {
            if let binary = _operator.as(BinaryOperatorExprSyntax.self),  ["==", "!=", "??"].contains(binary.operator.text) {
                return .visitChildren
            }
            matches.append(MutationWrapper(node: node, target: node.elements.first!.trimmedDescription))
        }

        return .visitChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let target = node.calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription {
//            targets.append(target)
            matches.append(MutationWrapper(node: node, target: target))
        }
        return .visitChildren
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text.contains("$") {
//            targets.append(node.baseName.text.replacingOccurrences(of: "$", with: ""))
            matches.append(MutationWrapper(node: node, target: node.baseName.text.replacingOccurrences(of: "$", with: "")))
        }
        return .visitChildren
    }

}

final class BindableReferenceCollector: SyntaxVisitor {

    lazy var targets: [String] =  matches.map(\.target)

    private(set) var matches = [MutationWrapper]()

    package init(_ view: StructDeclSyntax) {
        super.init(viewMode: .fixedUp)
        walk(view)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text.contains("$") {
            matches.append(MutationWrapper(node: node, target: node.baseName.text.replacingOccurrences(of: "$", with: "")))
        }
        return .visitChildren
    }

}
