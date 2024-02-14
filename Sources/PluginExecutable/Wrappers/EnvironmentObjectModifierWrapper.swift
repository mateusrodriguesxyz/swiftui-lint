import Foundation

struct EnvironmentObjectModifierWrapper: Codable {
    let property: String
    let type: String
    let targets: [String]
}
