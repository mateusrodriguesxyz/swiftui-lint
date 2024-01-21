import Foundation
import SwiftSyntax

struct Diagnostic: Codable {

    enum Kind: String, Codable {
        case error
        case warning
    }

    let origin: String
    let kind: Kind
    let location: SourceLocation
    let offset: Int
    let message: String
    
    var isError: Bool { kind == .error }

    init(origin: String, kind: Kind, location: SourceLocation, offset: Int, message: String) {
        self.origin = origin
        self.kind = kind
        self.location = location
        self.offset = offset
        self.message = message

    }

    func callAsFunction() {
        print("\(location.file):\(location.line):\(location.column + offset): \(kind.rawValue): \(message)")
    }

}

extension Diagnostic: Hashable { }
