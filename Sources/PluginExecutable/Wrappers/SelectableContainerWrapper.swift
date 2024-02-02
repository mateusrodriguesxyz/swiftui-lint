import SwiftSyntax

struct SelectableContainerWrapper {

    struct Selection {
        let property: PropertyDeclWrapper
        let node: ExprSyntax
        let name: String
        let type: TypeWrapper
    }

    enum Data {
        case range
        case array(_ reference: String)
    }

    var node: FunctionCallExprSyntax { decl }

    let decl: FunctionCallExprSyntax

    var name: String {
        return decl.calledExpression.trimmedDescription
    }

    var id: String? {

        let block = decl.trailingClosure?.statements.first?.item.as(FunctionCallExprSyntax.self)

        if block?.calledExpression.trimmedDescription == "ForEach" {
            return block?.arguments.first(where: { $0.label?.text == "id" })?.expression.as(KeyPathExprSyntax.self)?.components.first?.component.trimmedDescription
        } else {
            return decl.arguments.first(where: { $0.label?.text == "id" })?.expression.as(KeyPathExprSyntax.self)?.components.first?.component.trimmedDescription
        }

    }

    var children: CodeBlockItemListSyntax {
        return decl.trailingClosure?.statements ?? []
    }

    var block: FunctionCallExprSyntax? {
        if let block = decl.trailingClosure?.statements.first?.item.as(FunctionCallExprSyntax.self), block.calledExpression.trimmedDescription == "ForEach" {
            return block
        } else {
            if name == "List" {
                return decl
            } else {
                return nil
            }
        }
    }

    var expression: ExprSyntax? {
        return block?.arguments.first?.expression
    }

    var data: Data? {
        if expression?.is(SequenceExprSyntax.self) == true {
            return .range
        }
        if let reference = expression?.trimmedDescription {
            return .array(reference)
        }
        return nil
    }

    var content: SyntaxProtocol? {
        return block?.trailingClosure?.statements.first
    }

//    var selection: Selection? {
//        if let node = decl.arguments.first(where: { $0.label?.text == "selection" })?.expression {
//            return Selection(node: node)
//        }
//        return nil
//    }

    init(_ decl: FunctionCallExprSyntax) {
        self.decl = decl
    }


    func selection(from view: ViewDeclWrapper) -> Selection? {
        if let node = decl.arguments.first(where: { $0.label?.text == "selection" })?.expression {
            let name = String(node.trimmedDescription.dropFirst())
            if let property = view.property(named: name), let type = property._type {
                return Selection(property: property, node: node, name: name, type: type)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}
