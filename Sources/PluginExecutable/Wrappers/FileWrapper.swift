import SwiftSyntax
import SwiftParser
import Foundation

public struct FileWrapper {

    public let path: String
    public let source: SourceFileSyntax

    public var name: String {
        URL(string: path)!.lastPathComponent
    }

    public init?(path: String) {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        self.path = path
        self.source = Parser.parse(source: String(data: data, encoding: .utf8)!)
    }

}

func location(of node: SyntaxProtocol, in file: FileWrapper) -> SourceLocation {
    return node.startLocation(converter: .init(fileName: file.path, tree: file.source))
}

extension FileWrapper {

    init?(_ data: Data) {
        var file: FileWrapper?
        data.withUnsafeBytes {
            file = $0.bindMemory(to: FileWrapper.self).first
        }
        if let file {
            self = file
        } else {
            return nil
        }
    }

    var data: Data {
        var copy = self
        return withUnsafeBytes(of: &copy) { bytes in
            return Data(bytes)
        }
    }

}
