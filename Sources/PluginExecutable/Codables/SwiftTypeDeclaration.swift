import SwiftSyntax

struct SwiftTypeDeclaration: Codable {

    enum Kind: Codable {
        case `struct`
        case `class`
        case `actor`
        case `enum`
    }

    let location: SourceLocation
    let kind: Kind
    let name: String
    let properties: [SwiftPropertyDeclaration]
    let _properties: [String]
    let cases: [String]

    enum CodingKeys: String, CodingKey {
        case location
        case name = "_0_name"
        case kind = "_1_kind"
        case properties
        case _properties = "_3_properties"
        case cases
    }

    init(location: SourceLocation, kind: Kind, name: String, properties: [SwiftPropertyDeclaration], cases: [String]) {
        self.location = location
        self.kind = kind
        self.name = name
        self.properties = properties
        self._properties = properties.map(\.name)
        self.cases = cases
    }

}
