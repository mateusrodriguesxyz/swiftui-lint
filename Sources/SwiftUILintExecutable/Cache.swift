import SwiftSyntax
import Foundation

struct Cache: Codable {
    
    typealias FilePath = String

    var modificationDates: [FilePath: Date] = [:]
   
    var diagnostics: [FilePath: [Diagnostic]] = [:]
        
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
