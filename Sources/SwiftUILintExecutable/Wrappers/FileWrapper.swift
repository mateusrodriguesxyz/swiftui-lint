import SwiftSyntax
import SwiftParser
import Foundation

extension SourceLocationConverter {
    
    static var all = [String: SourceLocationConverter]()
    
    static func file(_ file: FileWrapper) -> SourceLocationConverter {
        SourceLocationConverter(fileName: file.path, tree: file.source)
//        if let converter = all[file.path] {
//            return converter
//        } else {
//            let converter = SourceLocationConverter(fileName: file.path, tree: file.source)
//            all[file.path] = converter
//            return converter
//        }
    }
    
}

struct FileWrapper {

    let path: String
    var source: SourceFileSyntax!
    
    var name: String? {
        URL(string: path)?.lastPathComponent
    }

    var hasChanges: Bool = true

    var modificationDate: Date? {
        try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date
    }

    init?(path: String, cache: Cache? = nil) {
        self.init(path: path, hasChanges: true)
        self.hasChanges = hasChanges(cache)
    }

    init?(path: String, hasChanges: Bool) {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        self.path = path
        self.source = parse(String(data: data, encoding: .utf8)!)
        self.hasChanges = hasChanges
    }

    init(_ content: String) {
        self.path = ""
        self.source = parse(content)
    }

    func location(of node: SyntaxProtocol) -> SourceLocation {
        return node.startLocation(converter: .file(self))
    }

    private func hasChanges(_ cache: Cache?) -> Bool {
        if let cache {
            if let cacheModificationDate = cache.modificationDates[path] {
                if let modificationDate, modificationDate > cacheModificationDate {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    private func parse(_ content: String) -> SourceFileSyntax {
        
//        Parser.parse(source: String(data: data, encoding: .utf8)!)
        
        var source: SourceFileSyntax!
        
        let work = DispatchWorkItem {
            source = Parser.parse(source: content)
        }
        
        let thread = Thread {
            work.perform()
        }
        
        thread.stackSize = 8 << 20
        
        thread.start()

        work.wait()
        
        return source
        
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
