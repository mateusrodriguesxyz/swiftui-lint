import SwiftSyntax

final class CallCollector: SyntaxVisitor {

    let name: String

    private(set) var matches = [CallWrapper]()

    private var decl: DeclReferenceExprSyntax?
    private var arguments: LabeledExprListSyntax?
    private var closure: ClosureExprSyntax?

    init(name: String, _ node: SyntaxProtocol) {
        self.name = name
        super.init(viewMode: .sourceAccurate)
        walk(node)
        if let decl, let arguments {
            matches.append(CallWrapper(node: decl, arguments: arguments, closure: closure))
        }
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        if node.baseName.text == name {
            if let decl, let arguments {
                matches.append(CallWrapper(node: decl, arguments: arguments, closure: closure))
                return .visitChildren
            }
            decl = node
        }
        return .visitChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        if decl != nil {
//            print("DID FIND ARGUMENTS FOR '\(name)'")
            arguments = node
            return .skipChildren
        }
        return .visitChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if decl != nil {
            closure = node
            if let decl, let arguments {
                matches.append(CallWrapper(node: decl, arguments: arguments, closure: closure))
                self.decl = nil
                return .visitChildren
            }
        }
        return .visitChildren
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        if node.trimmedDescription.contains(name) {
            return .visitChildren
        } else {
            return .skipChildren
        }
    }

}

// struct SheetWrapper {
//    
//    let decl: DeclReferenceExprSyntax
//    let labels: LabeledExprListSyntax
//    let closure: ClosureExprSyntax
//    
//    var isPresented: String? {
//        return labels.first(where: { $0.label?.text == "isPresented" })?.expression.trimmedDescription
//    }
//    
// }
//
// final class SheetCollector: SyntaxVisitor {
//    
//    private(set) var matches = [SheetWrapper]()
//     
//    private var decl: DeclReferenceExprSyntax?
//    private var labels: LabeledExprListSyntax?
//    private var closure: ClosureExprSyntax?
//    
//    init(_ node: SyntaxProtocol) {
//        super.init(viewMode: .sourceAccurate)
//        walk(node)
//    }
//    
//    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
//        if node.baseName.text == "sheet" {
//            decl = node
//        }
//        return .visitChildren
//    }
//    
//    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
//        if decl != nil {
//            labels = node
//        }
//        return .visitChildren
//    }
//    
//    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
//        if decl != nil {
//            closure = node
//            if let decl, let labels, let closure {
//                matches.append(SheetWrapper(decl: decl, labels: labels, closure: closure))
//                self.decl = nil
//            }
//        }
//        return .visitChildren
//    }
//    
// }
