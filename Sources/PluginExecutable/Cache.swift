import SwiftSyntax
import Foundation

struct Cache: Codable {
    
    typealias FilePath = String

    var modificationDates: [FilePath: Date] = [:]
    
    var diagnostics: [FilePath: [Diagnostic]] = [:]
    
    var destinations: [String: [String]] = [:]
    
    var mutations: [String: [String]] = [:]
    
//    var paths: [SourceLocation: NavigationPathCodable] = [:]

    func diagnostics(_ origin: some Diagnoser, file: String) -> [Diagnostic] {
        return diagnostics[String(describing: type(of: origin))]?.filter { $0.location.file == file } ?? []
    }

}

