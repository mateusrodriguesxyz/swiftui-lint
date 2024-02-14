import SwiftSyntax
import Foundation

struct Cache: Codable {
    
    typealias FilePath = String

    var modificationDates: [FilePath: Date] = [:]
    
    var diagnostics: [FilePath: [Diagnostic]] = [:]
    
    var destinations: [String: [String]] = [:]
    
    var mutations: [String: [String]] = [:]
    
//    var navigations: [SourceLocation: NavigationCache] = [:]

    func diagnostics(_ origin: some Diagnoser, file: String) -> [Diagnostic] {
        return diagnostics[String(describing: type(of: origin))]?.filter { $0.location.file == file } ?? []
    }
    
//    func fileHasChanges(_ file: String) -> Bool {
//        let modificationDate = try? FileManager.default.attributesOfItem(atPath: file)[.modificationDate] as? Date
//        if let cacheModificationDate = modificationDates[file] {
//            if let modificationDate, modificationDate > cacheModificationDate {
//                return true
//            } else {
//                return false
//            }
//        } else {
//            return true
//        }
//    }

}


//struct NavigationCache: Codable {
//    
//    let location: SourceLocation
//    let members: Set<String>
//    
//    func hasChanges(_ context: Context) -> Bool {
//        guard let cache = context.cache else {
//            return true
//        }
//        return members.contains {
//            context.destinations[$0] != cache.destinations[$0]
//        }
//    }
//    
//}

