import SwiftSyntax
import SwiftOperators

enum TypeWrapper: Codable {

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
        if case .set(_) = self {
            return true
        } else {
            return false
        }
    }

}

extension TypeWrapper {

    init(_ type: TypeSyntax) {
        let description = type.trimmedDescription
        if let baseType = description.firstMatch(of: #/(.*?)\?/#)?.output.1 {
            self = .optional(String(baseType))
            return
        }
        if let baseType = description.firstMatch(of: #/\[(.*?)\]/#)?.output.1 {
            self = .array(String(baseType))
            return
        }
        if let baseType = description.firstMatch(of: #/Set\<(.*?)\>/#)?.output.1 {
            self = .set(String(baseType))
            return
        }
        if let baseType = description.firstMatch(of: #/Optional\<(.*?)\>/#)?.output.1 {
            self = .optional(String(baseType))
            return
        }
        if let baseType = description.firstMatch(of: #/Array\<(.*?)\>/#)?.output.1 {
            self = .array(String(baseType))
            return
        }
        self = .plain(description)
    }

//    init(_ type: TypeSyntax) {
//        let description = type.trimmedDescription
//        if description.last == "?" {
//            self = .optional(String(description.dropLast()))
//        }
//        else if description.first == "[" {
//            self = .array(String(description.dropFirst().dropLast()))
//        }
//        else if description.contains("Set<") {
//            self = .set(description.replacingOccurrences(of: "Set<", with: "").replacingOccurrences(of: ">", with: ""))
//        }
//        else {
//            self = .plain(description)
//        }
//    }

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

            return
        }

        if let baseType {
            self = isArrayExpression ? .array(baseType) : .plain(baseType)
        } else {
            return nil
        }
    }

}

extension SyntaxProtocol {

    var typeName: String? {
        return self.as(StructDeclSyntax.self)?.name.text ?? self.as(ClassDeclSyntax.self)?.name.text ?? self.as(EnumDeclSyntax.self)?.name.text ?? self.as(ActorDeclSyntax.self)?.name.text
    }

    func properties(_ context: Context) -> [PropertyDeclWrapper] {

        guard let typeName else {
            return []
        }

        var properties = PropertyCollector(self).properties

        for _extension in context.extensions(of: typeName) {
            properties.append(contentsOf: PropertyCollector(_extension).properties)
        }

        return properties

    }

}

extension TypeWrapper {

    init?(_ expression: ExprSyntax, in context: Context, baseType: SyntaxProtocol? = nil) {

        guard let expression = expression.as(MemberAccessExprSyntax.self) else {

            if let baseType {
                if let expression = expression.as(ArrayExprSyntax.self), let referenceName = expression.elements.first?.expression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                    if let propertyBaseType = baseType.properties(context).first(where: { $0.name == referenceName })?._type(context)?.description {
                        self = .array(propertyBaseType)
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
