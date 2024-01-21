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
    
    init(_ type: TypeSyntax, context: Context? = nil) {
        
        // T.U
        if let type = type.as(MemberTypeSyntax.self) {
            // T.ID
            if type.name.text == "ID", let baseType = context?.type(named: type.baseType.trimmedDescription) {
                if let inheritanceClause = baseType.inheritanceClause, inheritanceClause.trimmedDescription.contains("Identifiable") {
                    if let id = baseType.property(named: "id", context: context), let idType = id._type(context) {
                        self = idType
                        return
                    }
                }
            }
            self = .plain(type.name.text)
            return
        }
        
        // T?
        if let type = type.as(OptionalTypeSyntax.self) {
            self = .optional(.init(type.wrappedType, context: context))
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
        self = .plain(type.trimmedDescription)
    }
    
    init?(_ expression: ExprSyntax?, context: Context?, parentType: TypeDeclSyntaxProtocol? = nil) {
        
        if
            let parentType,
            let referenceName = expression?.as(DeclReferenceExprSyntax.self)?.baseName.text,
            let propertyType = parentType.property(named: referenceName, context: context)?._type(context)
        {
            self = propertyType
            return
        }
        
        if let expression = expression?.as(MemberAccessExprSyntax.self) ?? expression?.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self), let context {
            
            let referenceName = expression.declName.baseName.text
            
            if let baseExpression = expression.base?.as(MemberAccessExprSyntax.self) {
                if
                    let baseTypeName = TypeWrapper(.init(baseExpression), context: context)?.description,
                    let baseType = context.type(named: baseTypeName),
                    let propertyType = baseType.property(named: referenceName, context: context)?._type(context)
                {
                    self = propertyType
                    return
                }
                return nil
            }
            
            if 
                let baseTypeName = expression.base?.trimmedDescription,
                let baseType = context.type(named: baseTypeName)
            {
                
                if let baseType = baseType.as(EnumDeclSyntax.self), CaseCollector(baseType).matches.contains(referenceName) {
                    self = .plain(baseType.name.text)
                    return
                }
                
                if let propertyType = baseType.property(named: referenceName, context: context)?._type(context, baseType: baseType) {
                    self = propertyType
                    return
                }
                
            }
            
        }
        
        // = ""
        if let type = literal(expression) {
            self = .plain(type)
            return
        }
        
        // = [T()]
        if
            let expression = expression?.as(ArrayExprSyntax.self)?.elements.first?.expression,
            let baseType = TypeWrapper(expression, context: context, parentType: parentType)
        {
            self = .array(baseType)
            return
        }
        
        if let initializer = expression?.as(FunctionCallExprSyntax.self) {
            
            // = Optional(T())
            if
                initializer.calledExpression.trimmedDescription == "Optional",
                let expression = initializer.arguments.first?.expression,
                let baseType = TypeWrapper(expression, context: context)
            {
                self = .optional(baseType)
                return
            }
            
            // = Set<T>()
            if
                initializer.calledExpression.trimmedDescription.contains("Set"),
                let type = initializer.calledExpression.as(GenericSpecializationExprSyntax.self)?.genericArgumentClause.arguments.first?.argument
            {
                self = .set(.init(type, context: context))
                return
            }
            
            // = T()
            self = .plain(initializer.calledExpression.trimmedDescription)
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

extension InfixOperatorExprSyntax {
    
    init?(_ expression: ExprSyntax?) {
        if let sequence = expression?.as(SequenceExprSyntax.self){
            
            let expression = (try? OperatorTable().foldSingle(sequence))?.as(InfixOperatorExprSyntax.self)
            
            if let expression {
                self = expression
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}
