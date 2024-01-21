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
        if let type = TypeWrapper(expression, context: nil)?.baseType {
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

    //    var type: TypeWrapper? {
    //        if let expression = node.item.as(FunctionCallExprSyntax.self)?.arguments.first?.expression {
    //            return TypeWrapper(expression)
    //        } else {
    //            return nil
    //        }
    //    }

    init?(node: CodeBlockItemSyntax) {
        if let name = node.item.as(FunctionCallExprSyntax.self)?.calledExpression.trimmedDescription, (name == "ForEach" || name == "List") {
            self.node = node
        } else {
            return nil
        }
    }

}
