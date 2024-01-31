import SwiftSyntax

struct PropertyDeclWrapper: MemberWrapperProtocol {

    var node: SyntaxProtocol { decl }

    let decl: VariableDeclSyntax

    init(decl: VariableDeclSyntax) {
        self.decl = decl
    }

    var attributes: Set<String> {
        return Set(decl.attributes.map(\.trimmedDescription))
    }

    var name: String {
        return decl.bindings.first!.pattern.trimmedDescription
    }

    var baseType: String? {
        return _type?.baseType
    }

    var _type: TypeWrapper? {
        guard let binding = decl.bindings.first else { return nil }

        if let type = binding.typeAnnotation?.type {
            return TypeWrapper(type)
        }

        if let type = binding.initializer?.value.as(FunctionCallExprSyntax.self)?.calledExpression.trimmedDescription {
            if type.last == "?" {
                return .optional(String(type.dropLast()))
            } else {
                return .plain(type)
            }
        }

        let value = binding.initializer?.value

        return TypeWrapper(value)

    }

    var type: String? {
        return _type?.description
    }

    var hasInitializer: Bool {
        return decl.bindings.first?.initializer != nil
    }

    var isOptional: Bool {
        return _type?.description.last == "?"
    }

    var isStatic: Bool {
        return decl.modifiers.trimmedDescription.contains("static")
    }

    var block: CodeBlockItemListSyntax? {
        return decl.bindings.first?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self)
    }

    func _type(_ context: Context, baseType: SyntaxProtocol? = nil) -> TypeWrapper? {
        if let _type {
            return _type
        }
        if let value = decl.bindings.first?.initializer?.value {
            return TypeWrapper(value, in: context, baseType: baseType)
//            return TypeWrapper(value, in: context)
        } else {
            return nil
        }
    }

    func baseType(_ context: Context) -> String? {
        return _type?.baseType
    }

    func isReferencingSingleton(context: Context) -> Bool {

        guard let initializer = decl.bindings.first?.initializer else {
            return false
        }

        guard let expression = initializer.value.as(MemberAccessExprSyntax.self) else { return false }

        guard  let name = expression.firstToken(viewMode: .sourceAccurate)?.text else {
            return false
        }

        guard  let type = context.type(named: name) else {
            return false
        }

        guard let reference = expression.trimmedDescription.components(separatedBy: ".").dropFirst().first else {
            return false
        }


        if let _ = PropertyCollector(type).properties.first(where: { $0.name == reference && $0.isStatic  }) {
            return true
        }

        return false

    }

}
