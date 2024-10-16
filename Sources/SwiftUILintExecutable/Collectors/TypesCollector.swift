import SwiftSyntax

final class TypesDeclCollector: SyntaxVisitor {

    enum Kind {
        case `struct`
        case `enum`
        case `class`
        case `actor`
        case `extension`
    }

    private(set) var structs = [StructDeclSyntax]()
    private(set) var enums = [EnumDeclSyntax]()
    private(set) var classes = [ClassDeclSyntax]()
    private(set) var actors = [ActorDeclSyntax]()
    private(set) var extensions = [ExtensionDeclSyntax]()

    var all: [TypeDeclSyntaxProtocol] { structs + enums + classes + actors }

    private let kinds: [Kind]

    init(_ file: FileWrapper, kinds: [Kind] = []) {
        self.kinds = kinds
        super.init(viewMode: .sourceAccurate)
        walk(file.source)
    }

    init(_ files: [FileWrapper], kinds: [Kind] = []) {
        self.kinds = kinds
        super.init(viewMode: .sourceAccurate)
        for file in files {
            walk(file.source)
        }
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if kinds.isEmpty || kinds.contains(.struct) {
            structs.append(node)
        }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if kinds.isEmpty || kinds.contains(.enum) {
            enums.append(node)
        }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if kinds.isEmpty || kinds.contains(.class) {
            classes.append(node)
        }
        return .skipChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        if kinds.isEmpty || kinds.contains(.actor) {
            actors.append(node)
        }
        return .skipChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        if kinds.isEmpty || kinds.contains(.extension) {
            extensions.append(node)
        }
        return .skipChildren
    }

}

protocol TypeDeclSyntaxProtocol: SyntaxProtocol {

    var name: TokenSyntax { get }
    var inheritanceClause: InheritanceClauseSyntax? { get }

}

extension StructDeclSyntax: TypeDeclSyntaxProtocol { }

extension EnumDeclSyntax: TypeDeclSyntaxProtocol { }

extension ClassDeclSyntax: TypeDeclSyntaxProtocol { }

extension ActorDeclSyntax: TypeDeclSyntaxProtocol { }

extension TypeDeclSyntaxProtocol {

    func properties(_ context: Context?) -> [PropertyDeclWrapper] {
        var properties = PropertyCollector(self).properties
        if let context {
            for _extension in context.extensions(of: name.text) {
                properties.append(contentsOf: PropertyCollector(_extension).properties)
            }
        }
        return properties
    }
    
    func property(named name: String, context: Context?) -> PropertyDeclWrapper? {
        return properties(context).first(where: { $0.name == name })
    }

}

