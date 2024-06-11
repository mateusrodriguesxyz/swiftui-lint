import SwiftSyntax

final class AnyCallCollector: SyntaxVisitor {
    
    private let names: Set<String>
    private let skipChildrenOf: String?

    private var skipNextClosureExprSyntax = false

    private(set) var matches = [CallWrapper]()
    
    var calls: [FunctionCallExprSyntax] {
        matches.compactMap {
            $0.node.parent(FunctionCallExprSyntax.self)
        }
        .filter {
            names.contains($0.calledExpression.trimmedDescription)
        }
    }
    
    private var decl: DeclReferenceExprSyntax?
    private var arguments: LabeledExprListSyntax?
    private var closure: ClosureExprSyntax?

    init(_ names: [String], skipChildrenOf: String? = nil, from node: SyntaxProtocol) {
        self.names = Set(names)
        self.skipChildrenOf = skipChildrenOf
        super.init(viewMode: .sourceAccurate)
        guard node.trimmedDescription.contains(anyOf: names) else {
            return
        }
        walk(node)
        buildMatch()
    }
    
    @discardableResult
    func buildMatch() -> Bool {
        if let decl, names.contains(decl.trimmedDescription), let arguments {
            matches.append(CallWrapper(node: decl, arguments: arguments, closure: closure))
            self.decl = nil
            self.arguments = nil
            self.closure = nil
            return true
        } else {
            return false
        }
    }
    
    convenience init(_ name: String, skipChildrenOf: String? = nil, from node: SyntaxProtocol) {
        self.init([name], skipChildrenOf: skipChildrenOf, from: node)
    }
    
    convenience init(name: String, _ node: SyntaxProtocol) {
        self.init([name], skipChildrenOf: nil, from: node)
    }
    
    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        buildMatch()
        if names.contains(node.baseName.text) {
            decl = node
        }
        if let skipChildrenOf, node.baseName.text == skipChildrenOf {
            skipNextClosureExprSyntax = true
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if decl != nil {
            arguments = node
            return .skipChildren
        }
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if decl != nil {
            closure = node
            if buildMatch() {
                return .visitChildren
            }
        }
        if skipNextClosureExprSyntax {
            skipNextClosureExprSyntax = false
            return .skipChildren
        } else {
            return .visitChildren
        }
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(anyOf: names) {
            return .visitChildren
        } else {
            return .skipChildren
        }
    }
    
}
