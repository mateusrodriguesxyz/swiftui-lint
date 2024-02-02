import SwiftSyntax
import SwiftParser
import Foundation

public struct FileWrapper {

    public let path: String
    public let source: SourceFileSyntax

    public var name: String {
        URL(string: path)!.lastPathComponent
    }

    public var hasChanges: Bool {
        if let cache = Cache.default {
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

    public var modificationDate: Date {
        if let modificationDate = try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date {
            return modificationDate
        } else {
            return .now
        }
    }

    init?(path: String, cache: Cache? = nil) {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        self.path = path
        self.source = Parser.parse(source: String(data: data, encoding: .utf8)!)
    }

    init(_ content: String) {
        self.path = ""
        self.source = Parser.parse(source: content)
    }

    func location(of node: SyntaxProtocol) -> SourceLocation {
        return node.startLocation(converter: .init(fileName: self.path, tree: self.source))
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
