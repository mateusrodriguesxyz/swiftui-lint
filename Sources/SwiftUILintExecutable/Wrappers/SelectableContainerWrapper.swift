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

    var children: CodeBlockItemListSyntax {
        return decl.trailingClosure?.statements ?? []
    }

    init(_ decl: FunctionCallExprSyntax) {
        self.decl = decl
    }


    func selection(from view: ViewDeclWrapper, context: Context) -> Selection? {
        if let node = decl.arguments.first(where: { $0.label?.text == "selection" })?.expression {
            let name = String(node.trimmedDescription.dropFirst())
            if let property = view.property(named: name), let type = property._type(context) {
                return Selection(property: property, node: node, name: name, type: type)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}
