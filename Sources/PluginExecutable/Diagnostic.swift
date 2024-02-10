import Foundation
import PluginCore
import SwiftSyntax

enum Diagnostics {

//    static var emitted: [Diagnostic] = []

//    static func emit(_ origin: some Diagnoser, _ kind: Diagnostic.Kind, message: String, node: SyntaxProtocol, offset: Int = 0, file: FileWrapper) {
//        emit(origin: String(describing: type(of: origin)), kind, message: message, location: file.location(of: node), offset: offset)
//    }
//
//    static func emit(origin: String? = nil, _ kind: Diagnostic.Kind, message: String, node: SyntaxProtocol, offset: Int = 0, file: FileWrapper) {
//        emit(origin: origin, kind, message: message, location: file.location(of: node), offset: offset)
//    }
//
//    static func emit(origin: String? = nil, _ kind: Diagnostic.Kind, message: String, location: SourceLocation, offset: Int = 0) {
//        let diagnostic = Diagnostic(origin: origin, kind: kind, location: location, offset: offset, message: message)
//        emit(diagnostic)
//    }
//
//    static func emit(_ diagnostic: Diagnostic) {
//        diagnostic()
//        emitted.append(diagnostic)
//    }

//    static func clear() {
//        emitted = []
//    }

}

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

    init(origin: String, kind: Kind, location: SourceLocation, offset: Int, message: String) {
        self.origin = origin
        self.kind = kind
        self.location = location
        self.offset = offset
        self.message = message

    }

    func callAsFunction() {
        print("\(location.file):\(location.line):\(location.column + offset): \(kind.rawValue): 🔵 \(message)")
    }

}

extension Diagnostic: Hashable { }
