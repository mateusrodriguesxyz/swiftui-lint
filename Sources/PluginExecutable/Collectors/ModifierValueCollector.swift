import SwiftSyntax

final class TagCollector: SyntaxVisitor {

    var match: LabeledExprSyntax?

    var position: AbsolutePosition?

    private var collect: Bool = false

    package init(_ node: SyntaxProtocol, position: AbsolutePosition? = nil) {
        super.init(viewMode: .sourceAccurate)
        self.position = position
        walk(node)
    }

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if match != nil {
            return .skipChildren
        }
        if let position {
            if node.position >= position, node.baseName.text == "tag" {
                collect = true
            }
        } else {
            if node.baseName.text == "tag" {
                collect = true
            }
        }
        return .skipChildren
    }

    override func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
        if collect {
            match = node
            collect = false
        }
        return .skipChildren
    }

}

final class ModifierValueCollector: SyntaxVisitor {

    private(set) var match: LabeledExprSyntax?

    var position: AbsolutePosition?

    package init(_ node: SyntaxProtocol, position: AbsolutePosition? = nil) {
        super.init(viewMode: .sourceAccurate)
        self.position = position
        walk(node)
    }

    package init(_ node: SyntaxProtocol) {
        super.init(viewMode: .sourceAccurate)
        walk(node)
    }

    override func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
        if match == nil, let position, node.position > position {
            match = node
        }
        return .skipChildren
    }

}

final class ModifierValueCollector2: SyntaxVisitor {

    private(set) var match: LabeledExprListSyntax?

    var position: AbsolutePosition?

    package init(_ node: SyntaxProtocol, position: AbsolutePosition? = nil) {
        super.init(viewMode: .sourceAccurate)
        self.position = position
        walk(node)
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if match == nil, let position, node.position > position {
            match = node
        }
        return .skipChildren
    }

}

struct ModifierArgumentWrapper {

    let node: LabeledExprSyntax

    var label: String? { node.label?.text }

    var value: ExprSyntax { node.expression }

}

struct ModifierArgumentListWrapper: Sequence {

    let node: LabeledExprListSyntax

    var labels: [String?] {
        return node.map(\.label?.text)
    }

    subscript(label: String) -> ModifierArgumentWrapper? {
        return node.first(where: { $0.label?.text == label }).map({ ModifierArgumentWrapper(node: $0) })
    }

    func makeIterator() -> AnyIterator<ModifierArgumentWrapper> {

        var _iterator = node.makeIterator()

        return AnyIterator {
            return _iterator.next().map({ ModifierArgumentWrapper(node: $0) })
        }

    }

}
