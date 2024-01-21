import SwiftSyntax

struct ForEachWrapper {

    enum Data {
        case range
        case property(_ name: String)
        case array(_ type: String)
    }

    let node: CodeBlockItemSyntax

    var id: String? { 
        return node.item.as(FunctionCallExprSyntax.self)?.arguments.first(where: { $0.label?.text == "id" })?.expression.as(KeyPathExprSyntax.self)?.components.first?.component.trimmedDescription
    }



    var data: Data? {
        let expression = node.item.as(FunctionCallExprSyntax.self)?.arguments.first?.expression
        if expression?.is(SequenceExprSyntax.self) == true {
            return .range
        }
        if let type = TypeWrapper(expression)?.baseType {
            return .array(type)
        }
        if let name = expression?.trimmedDescription {
            return .property(name)
        }
        return nil
    }

    var content: CodeBlockItemSyntax? {
        return node.item.as(FunctionCallExprSyntax.self)?.trailingClosure?.statements.first
    }

    var type: TypeWrapper? {
        if let expression = node.item.as(FunctionCallExprSyntax.self)?.arguments.first?.expression {
            return TypeWrapper(expression)
        } else {
            return nil
        }
    }

    init?(node: CodeBlockItemSyntax) {
        if node.item.as(FunctionCallExprSyntax.self)?.calledExpression.trimmedDescription == "ForEach" {
            self.node = node
        } else {
            return nil
        }
    }

}

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
