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

    var block: CodeBlockItemListSyntax? {
        return decl.bindings.first?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self)
    }

    func baseType(_ context: Context) -> String? {
        if let baseType = _type?.baseType {
            return baseType
        }
        if let value = decl.bindings.first?.initializer?.value {
            return TypeWrapper(value, in: context)?.baseType
        } else {
            return nil
        }
    }

}
