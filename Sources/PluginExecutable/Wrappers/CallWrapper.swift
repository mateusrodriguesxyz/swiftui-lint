import SwiftSyntax

struct CallWrapper {

    let node: DeclReferenceExprSyntax
    let arguments: LabeledExprListSyntax
    let closure: ClosureExprSyntax?

    var name: String {
        return node.baseName.text
    }

    func argument(_ argument: String) -> String? {
        return arguments.first(where: { $0.label?.text == argument })?.expression.trimmedDescription
    }

}
