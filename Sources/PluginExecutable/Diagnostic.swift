import Foundation
import PluginCore
import SwiftSyntax

enum Diagnostics {

    private(set) static var emitted: [Diagnostic] = []

    static func emit(_ kind: Diagnostic.Kind, message: String, node: SyntaxProtocol, offset: Int = 0, file: FileWrapper) {
        emit(kind, message: message, location: file.location(of: node), offset: offset)
    }

    static func emit(_ kind: Diagnostic.Kind, message: String, location: SourceLocation, offset: Int = 0) {
        let diagnostic = Diagnostic(kind, location: location, offset: offset, message: message)
        diagnostic()
        emitted.append(diagnostic)
    }

}

struct Diagnostic {

    enum Kind: String {
        case error
        case warning
    }

    let kind: Kind
    let location: SourceLocation
    let offset: Int
    let message: String

    init(_ kind: Kind, location: SourceLocation, offset: Int, message: String) {
        self.kind = kind
        self.location = location
        self.offset = offset
        self.message = message
    }

    func callAsFunction() {
        print("\(location.file):\(location.line):\(location.column + offset): \(kind.rawValue): 🔵 \(message)")
    }

}
