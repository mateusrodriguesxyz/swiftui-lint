import SwiftSyntax

final class ModifiersDeclCollector: SyntaxVisitor {

    private(set) var modifiers: [String] = []

    init(_ files: [FileWrapper]) {
        super.init(viewMode: .sourceAccurate)
        for file in files {
            walk(file.source)
        }
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.extendedType.trimmedDescription == "View" {
            return .visitChildren
        } else {
            return .skipChildren
        }
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.signature.returnClause?.trimmedDescription.contains("some View") == true {
            modifiers.append(node.name.text)
        }
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

}
