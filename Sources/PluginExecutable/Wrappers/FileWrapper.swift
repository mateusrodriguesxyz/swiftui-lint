import SwiftSyntax
import SwiftParser
import Foundation

struct FileWrapper {

    let path: String
    let source: SourceFileSyntax

    var name: String {
        URL(string: path)!.lastPathComponent
    }

    var hasChanges: Bool = true

    var modificationDate: Date {
        if let modificationDate = try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date {
            return modificationDate
        } else {
            return .now
        }
    }

    init?(path: String, hasChanges: Bool) {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        self.path = path
        self.source = Parser.parse(source: String(data: data, encoding: .utf8)!)
        self.hasChanges = hasChanges
    }

    init?(path: String, cache: Cache? = nil) {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        self.path = path
        self.source = Parser.parse(source: String(data: data, encoding: .utf8)!)
        self.hasChanges = hasChanges(cache)
    }

    init(_ content: String) {
        self.path = ""
        self.source = Parser.parse(source: content)
    }

    func location(of node: SyntaxProtocol) -> SourceLocation {
        return node.startLocation(converter: .init(fileName: self.path, tree: self.source))
    }

    private func hasChanges(_ cache: Cache?) -> Bool {
        if let cache {
            if let cacheModificationDate = cache.modificationDates[path] {
                if modificationDate > cacheModificationDate {
                    return true
                }
            }
            return false
        } else {
            return true
        }
    }

}

//extension FileWrapper {
//
//    init?(_ data: Data) {
//        var file: FileWrapper?
//        data.withUnsafeBytes {
//            file = $0.bindMemory(to: FileWrapper.self).first
//        }
//        if let file {
//            self = file
//        } else {
//            return nil
//        }
//    }
//
//    var data: Data {
//        var copy = self
//        return withUnsafeBytes(of: &copy) { bytes in
//            return Data(bytes)
//        }
//    }
//
//}
