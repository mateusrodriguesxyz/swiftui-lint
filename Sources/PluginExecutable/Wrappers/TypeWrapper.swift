import SwiftSyntax
import SwiftOperators

enum TypeWrapper {

    case plain(String)
    case optional(String)
    case array(String)
    case set(String)

    var description: String {
        switch self {
            case .plain(let type):
                return type
            case .optional(let type):
                return "\(type)?"
            case .array(let type):
                return "[\(type)]"
            case .set(let type):
                return "Set<\(type)>"
        }
    }

    var baseType: String {
        switch self {
            case .plain(let type):
                return type
            case .optional(let type):
                return type
            case .array(let type):
                return type
            case .set(let type):
                return type
        }
    }

    var isSet: Bool {
        if case let .set(_) = self {
            return true
        } else {
            return false
        }
    }

}

extension TypeWrapper {

    init(_ type: TypeSyntax) {
        let description = type.trimmedDescription
        if description.last == "?" {
            self = .optional(String(description.dropLast()))
        }
        else if description.first == "[" {
            self = .array(String(description.dropFirst().dropLast()))
        }
        else if description.contains("Set<") {
            self = .set(description.replacingOccurrences(of: "Set<", with: "").replacingOccurrences(of: ">", with: ""))
        }
        else {
            self = .plain(description)
        }
    }

    init?(_ expression: ExprSyntax, in context: Context) {
        guard let expression = expression.as(MemberAccessExprSyntax.self) else { return nil }

        guard  let name = expression.base?.trimmedDescription, let decl = context.type(named: name) else {
            return nil
        }

        if let _enum = context.enums.first(where: { $0.name.text == name }) {
            if CaseCollector(_enum).matches.contains(expression.declName.baseName.text) {
                self = .plain(_enum.name.text)
                return
            }
        }

//        if let _class = context.classes.first(where: { $0.name.text == name }) {
//            if let property = PropertyCollector(_class).properties.first(where: { $0.name == name && $0.isOptional  }) {
//                if let _type = property._type {
//                    self = _type
//                    return
//                }
//            }
//        }
//
//        if let _actor = context.actors.first(where: { $0.name.text == name }) {
//            if let property = PropertyCollector(_actor).properties.first(where: { $0.name == name && $0.isOptional  }) {
//                if let _type = property._type {
//                    self = _type
//                    return
//                }
//            }
//        }

        if
            let property = PropertyCollector(decl).properties.first(where: { $0.name == expression.declName.baseName.text }),
            let _type = property._type {
            self = _type
        } else {
            return nil
        }
    }

    init?(_ expression: ExprSyntax?) {

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

        let isArrayExpression = expression?.is(ArrayExprSyntax.self) ?? false

        var expression = expression?.as(ArrayExprSyntax.self)?.elements.first?.expression ?? expression

        if let initializer = expression?.as(FunctionCallExprSyntax.self), initializer.calledExpression.trimmedDescription == "Optional" {
            expression = initializer.arguments.first?.expression
            if let baseType = literal(expression) {
                self = .optional(baseType)
                return
            }
        }

        var baseType: String?

        // value = [T(), T(), T()]
        if let type = expression?.as(FunctionCallExprSyntax.self)?.calledExpression.trimmedDescription {
            baseType = type
        }

        baseType = literal(expression)

        if let sequence = expression?.as(SequenceExprSyntax.self), let expression = (try? OperatorTable().foldSingle(sequence))?.as(AsExprSyntax.self) {

//            print("warning: AsExprSyntax = \(expression.trimmedDescription), type = \(expression.type.trimmedDescription)")

            if let identifier = expression.type.as(IdentifierTypeSyntax.self), identifier.name.text == "Optional" {
                self = .optional(identifier.genericArgumentClause!.arguments.trimmedDescription)
                return
            }

            let type = expression.type.trimmedDescription

            if type.last == "?" {
                self = .optional(String(type.dropLast()))
            } else {
                self = .plain(type)
            }

//            print("warning: self = \(self)")

            return
        }

        if let baseType {
            self = isArrayExpression ? .array(baseType) : .plain(baseType)
        } else {
            return nil
        }
    }

}
