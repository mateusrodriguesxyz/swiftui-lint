import SwiftSyntax

struct PropertyDeclWrapper: MemberWrapperProtocol {
        
    let node: VariableDeclSyntax
    
    init(decl: VariableDeclSyntax) {
        self.node = decl
    }
    
    var attributes: Set<String> {
        return Set(node.attributes.map(\.trimmedDescription))
    }
    
    var name: String {
        return node.bindings.first!.pattern.trimmedDescription
    }
    
    var hasInitializer: Bool {
        return node.bindings.first?.initializer != nil
    }
    
    var isStatic: Bool {
        return node.modifiers.trimmedDescription.contains("static")
    }
    
    var isPrivate: Bool {
        return node.modifiers.contains(where: { $0.name.text == "private" })
    }
    
    var block: CodeBlockItemListSyntax? {
        return node.bindings.first?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self)
    }
    
    var type: String? {
        _type?.description
    }
    
    var _type: TypeWrapper? {
        _type(nil)
    }
    
    func _type(_ context: Context?, baseType: TypeDeclSyntaxProtocol? = nil) -> TypeWrapper? {
        if let binding = node.bindings.first {
            if let type = binding.typeAnnotation?.type {
                return TypeWrapper(type, context: context)
            }
            if let value = binding.initializer?.value, let type = TypeWrapper(value) {
                return type
            }
        }
        if let context, let value = node.bindings.first?.initializer?.value, let type = TypeWrapper(value, in: context, baseType: baseType)  {
            return type
        }
        if
            let environment = node.attributes.first(where: { $0.trimmedDescription.contains("@Environment") }),
            let keyPath = environment.child(KeyPathPropertyComponentSyntax.self)?.trimmedDescription,
            let type = SwiftUIEnvironmentValues.type(of: keyPath)
        {
            return .plain(type)
        }
        return nil
    }
    
    func baseType(_ context: Context) -> String? {
        return _type(context)?.baseType
    }
    
    
    
    func isReferencingSingleton(context: Context) -> Bool {
        
        let initializer = node.bindings.first!.initializer!
        
        guard let expression = initializer.value.as(MemberAccessExprSyntax.self) else {
            return false
        }
        
        guard let name = expression.firstToken(viewMode: .sourceAccurate)?.text else {
            return false
        }
        
        guard let reference = expression.trimmedDescription.components(separatedBy: ".").dropFirst().first else {
            return false
        }
        
        guard  let type = context.type(named: name) else {
            return false
        }
        
        if let _ = type.properties(context).first(where: { $0.name == reference && $0.isStatic  }) {
            return true
        }
        
        return false
        
    }
    
}



class ChildCollector<T: SyntaxProtocol>: SyntaxAnyVisitor {
    
    var match: T?
    
    init(_ node: some SyntaxProtocol) {
        super.init(viewMode: .all)
        walk(node)
    }
    
    override func visitAny(_ node: Syntax) -> SyntaxVisitorContinueKind {
        if match == nil, let node = node.as(T.self) {
            self.match = node.as(T.self)
        }
        return .visitChildren
    }
    
}

extension SyntaxProtocol {
    
    func child<T: SyntaxProtocol>(_ type: T.Type) -> T? {
        ChildCollector(self).match
    }
    
}
