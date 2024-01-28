import SwiftSyntax

final class TypesCollector<T: SyntaxProtocol>: SyntaxVisitor {

    private(set) var matches = [T]()

    init(source: SourceFileSyntax) {
        super.init(viewMode: .sourceAccurate)
        walk(source)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if T.self == StructDeclSyntax.self {
            matches.append(node as! T)
        }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if T.self == EnumDeclSyntax.self {
            matches.append(node as! T)
        }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if T.self == ClassDeclSyntax.self {
            matches.append(node as! T)
        }
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        if T.self == ActorDeclSyntax.self {
            matches.append(node as! T)
        }
        return .skipChildren
    }

}

final class TypesDeclCollector: SyntaxVisitor {

    private(set) var structs = [StructDeclSyntax]()
    private(set) var enums = [EnumDeclSyntax]()
    private(set) var classes = [ClassDeclSyntax]()
    private(set) var actors = [ActorDeclSyntax]()

    init(_ file: FileWrapper) {
        super.init(viewMode: .sourceAccurate)
        walk(file.source)
    }

    init(_ files: [FileWrapper]) {
        super.init(viewMode: .sourceAccurate)
        for file in files {
            walk(file.source)
        }
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        structs.append(node)
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        enums.append(node)
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        classes.append(node)
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        actors.append(node)
        return .skipChildren
    }

}
