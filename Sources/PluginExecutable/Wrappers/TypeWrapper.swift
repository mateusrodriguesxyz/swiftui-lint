import SwiftSyntax
import SwiftOperators

indirect enum TypeWrapper: Codable {

    case plain(String)
    case optional(Self)
    case array(Self)
    case set(Self)
    case dictionary(Self, Self)

    var description: String {
        switch self {
            case .plain(let type):
                return type
            case .optional(let type):
                return "\(type.description)?"
            case .array(let type):
                return "[\(type.description)]"
            case .set(let type):
                return "Set<\(type.description)>"
            case .dictionary(let keyType, let valueType):
                return "[\(keyType.description) : \(valueType.description)]"
        }
    }

    var baseType: String {
        switch self {
            case .plain(let type):
                return type
            case .optional(let type):
                return type.description
            case .array(let type):
                return type.description
            case .set(let type):
                return type.description
            case .dictionary(let keyType, let valueType):
                return "(\(keyType.description),\(valueType.description))"
        }
    }

    var isSet: Bool {
        if case .set(_) = self {
            return true
        } else {
            return false
        }
    }

}

extension TypeWrapper: Equatable { }

extension String.StringInterpolation {
    mutating func appendInterpolation(_ type: TypeWrapper) {
        appendInterpolation(
            String(describing: type)
                .replacingOccurrences(of: "PluginExecutable.TypeWrapper", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: ".", with: "")
        )
    }
}

extension TypeWrapper {

    init(_ type: TypeSyntax) {

        let description = type.trimmedDescription

        // T?
        if let type = type.as(OptionalTypeSyntax.self) {
            self = .optional(.init(type.wrappedType))
            return
        }

        // [T]
        if let type = type.as(ArrayTypeSyntax.self) {
            self = .array(.init(type.element))
            return
        }

        if let type = type.as(IdentifierTypeSyntax.self) {
            if let generic = type.genericArgumentClause?.arguments.first?.argument {
                // Optional<T>
                if type.name.text == "Optional" {
                    self = .optional(.init(generic))
                    return
                }
                // Set<T>
                if type.name.text == "Set" {
                    self = .set(.init(generic))
                    return
                }
                // Array<T>
                if type.name.text == "Array" {
                    self = .array(.init(generic))
                    return
                }
            }
        }

        // [Key:Value]
        if let type = type.as(DictionaryTypeSyntax.self) {
            self = .dictionary(TypeWrapper(type.key), TypeWrapper(type.value))
            return
        }

        // T
        self = .plain(description)
    }

    init?(_ expression: ExprSyntax?) {

        // = [T()]
        if let expression = expression?.as(ArrayExprSyntax.self), let element = expression.elements.first?.expression {
            if let baseType = TypeWrapper(element) {
                self = .array(baseType)
                return
            }
        }

        // = Optional(T())
        if let initializer = expression?.as(FunctionCallExprSyntax.self), initializer.calledExpression.trimmedDescription == "Optional" {
            if let expression = initializer.arguments.first?.expression, let baseType = TypeWrapper(expression) {
                self = .optional(baseType)
                return
            }
        }

        if let initializer = expression?.as(FunctionCallExprSyntax.self), initializer.calledExpression.trimmedDescription.contains("Set") {
            if let expression = initializer.arguments.first?.expression, let baseType = TypeWrapper(expression) {
                self = .set(baseType)
                return
            } else {
                if let baseType = initializer.calledExpression.as(GenericSpecializationExprSyntax.self)?.genericArgumentClause.arguments.first?.argument.trimmedDescription {
                    self = .set(.plain(baseType))
                    return
                }
            }
        }

        if (expression?.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)) != nil {
            return nil
        }

        // = T()
        if let type = expression?.as(FunctionCallExprSyntax.self)?.calledExpression.trimmedDescription {
            self = .plain(type)
            return
        }

        // = ""
        if let type = literal(expression) {
            self = .plain(type)
            return
        }

        // = ... as T
        if let expression = AsExprSyntax(expression) {
            self = TypeWrapper(expression.type)
            return
        }

        return nil
    }

}

func literal(_ expression: ExprSyntax?) -> String? {
    if expression?.is(StringLiteralExprSyntax.self) == true {
        return "String"
    }
    if expression?.is(IntegerLiteralExprSyntax.self) == true {
        return "Int"
    }
    if expression?.is(FloatLiteralExprSyntax.self) == true {
        return "Double"
    }
    if expression?.is(BooleanLiteralExprSyntax.self) == true {
        return "Bool"
    }
    return nil
}

extension AsExprSyntax {

    init?(_ expression: ExprSyntax?) {
        if let sequence = expression?.as(SequenceExprSyntax.self), let expression = (try? OperatorTable().foldSingle(sequence))?.as(AsExprSyntax.self) {
            self = expression
        } else {
            return nil
        }
    }

}

extension SyntaxProtocol {

    func properties(_ context: Context?) -> [PropertyDeclWrapper] {

        guard let typeName = (self as? TypeDeclSyntaxProtocol)?.name.text else {
            return []
        }

        var properties = PropertyCollector(self).properties

        if let context {
            for _extension in context.extensions(of: typeName) {
                properties.append(contentsOf: PropertyCollector(_extension).properties)
            }
        }

        return properties

    }

}

extension TypeWrapper {

    init?(_ expression: ExprSyntax, in context: Context, baseType: SyntaxProtocol? = nil) {

        if let expression = expression.as(ArrayExprSyntax.self), let element = expression.elements.first?.expression {
            if let baseType = TypeWrapper(element, in: context) {
                self = .array(baseType)
                return
            }
        }

        if let expression = expression.as(DeclReferenceExprSyntax.self) {
            let referenceName = expression.baseName.text
            if let baseType {
                if let propertyBaseType = baseType.properties(context).first(where: { $0.name == referenceName })?._type(context) {
                    self = propertyBaseType
                    return
                }
            }
        }

        guard let expression = expression.as(MemberAccessExprSyntax.self) ?? expression.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self) else {
            if let baseType {
                if let expression = expression.as(ArrayExprSyntax.self), let referenceName = expression.elements.first?.expression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                    if let propertyBaseType = baseType.properties(context).first(where: { $0.name == referenceName })?._type(context) {
                        self = .array(propertyBaseType)
                        return
                    }
                }
            }

            return nil
        }

        if let baseExpression = expression.base, baseExpression.is(MemberAccessExprSyntax.self) {
            if let baseTypeName = TypeWrapper(baseExpression, in: context)?.description, let baseType = context.type(named: baseTypeName) {
                let baseTypeProperties = baseType.properties(context)
                if let baseProperty = baseTypeProperties.first(where: { $0.name == expression.declName.baseName.text }) {
                    if let type = baseProperty._type(context) {
                        self = type
                        return
                    }
                }
            }
            return nil
        }

        guard  let baseName = expression.base?.trimmedDescription, let baseType = context.type(named: baseName) else {
            return nil
        }

        if let _enum = context.enums.first(where: { $0.name.text == baseName }) {
            if CaseCollector(_enum).matches.contains(expression.declName.baseName.text) {
                self = .plain(_enum.name.text)
                return
            }
        }

        var property: PropertyDeclWrapper?

        let baseTypeProperties = baseType.properties(context)

        if let baseProperty = baseTypeProperties.first(where: { $0.name == expression.declName.baseName.text }) {
            property = baseProperty
        }

        if
            let property,
            let _type = property._type(context, baseType: baseType) {
            self = _type
        } else {
            return nil
        }

    }

}
