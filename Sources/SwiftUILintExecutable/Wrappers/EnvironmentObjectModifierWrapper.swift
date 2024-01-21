import SwiftSyntax

struct EnvironmentObjectModifierWrapper {
    let node: SyntaxProtocol
    let property: String
    let type: String
    let targets: [String]
}
