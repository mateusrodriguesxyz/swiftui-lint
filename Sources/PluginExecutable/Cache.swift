//
//  File.swift
//
//
//  Created by Mateus Rodrigues on 26/01/24.
//

import SwiftSyntax
import Foundation

struct SwiftFileDeclaration: Codable {

    let name: String
    let path: String?
    let types: [SwiftTypeDeclaration]

}

struct SwiftTypeDeclaration: Codable {

    enum Kind: Codable {
        case _struct
        case _class
        case _actor
        case _enum
    }

    let location: SourceLocation

    let kind: Kind

    let name: String

    let properties: [SwiftPropertyDeclaration]

    let cases: [String]

}

struct SwiftPropertyDeclaration: Codable {

    let location: SourceLocation

    let description: String

    let name: String

    let attributes: Set<String>

    let keywords: Set<String>

    let hasInitializer: Bool

    let type: TypeWrapper?

}

extension SwiftPropertyDeclaration {

    init(_ property: PropertyDeclWrapper, file: FileWrapper) {

        let node = property.node.as(VariableDeclSyntax.self)!

        self.location = file.location(of: node)
        self.description = property.node.trimmedDescription
        self.name = property.name
        self.attributes = property.attributes
        self.keywords = Set(node.modifiers.map(\.name.text) + [node.bindingSpecifier.text])
        self.hasInitializer = property.hasInitializer
        self.type = property._type
    }

}

func cache(_ context: Context, pluginWorkDirectory: String) throws {

    try? FileManager.default.createDirectory(at: URL(filePath: pluginWorkDirectory).appending(path: "cache"), withIntermediateDirectories: false)

    for file in context.files {

        let name = URL(filePath: file.path).lastPathComponent

        guard let modificationDate = try FileManager.default.attributesOfItem(atPath: file.path)[.modificationDate] as? Date else { continue }

        let cached = URL(filePath: pluginWorkDirectory).appending(path: "cache/\(name).json")

        guard let cachedModificationDate = try? FileManager.default.attributesOfItem(atPath: cached.path())[.modificationDate] as? Date else { continue }

        if modificationDate < cachedModificationDate {
            continue
        }

        print("warning: caching '\(name)'...")

        var types = [SwiftTypeDeclaration]()

        let _structs = TypesDeclCollector(file).structs
//            .filter { node in
//                (node.inheritanceClause?.trimmedDescription.contains("View") ?? false) == false && node.name.text.contains("_Previews") == false
//            }

        _structs.forEach { node in

            let name = node.name.text
            let properties = PropertyCollector(node).properties.map({ SwiftPropertyDeclaration($0, file: file) })

            types.append(SwiftTypeDeclaration(location: file.location(of: node), kind: ._struct, name: name, properties: properties, cases: []))

        }

        let _enums = TypesDeclCollector(file).enums

        _enums.forEach { node in
            let name = node.name.text
            let properties = PropertyCollector(node).properties.map({ SwiftPropertyDeclaration($0, file: file) })
            let cases = CaseCollector(node).matches
            types.append(SwiftTypeDeclaration(location: file.location(of: node), kind: ._struct, name: name, properties: properties, cases: cases))
        }

        if types.isEmpty {
            continue
        }

        let file = SwiftFileDeclaration(name: file.name, path: file.path, types: types)

        let encoder = JSONEncoder()

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(file)

        try data.write(to: URL(filePath: pluginWorkDirectory).appending(path: "cache/\(file.name).json"))


    }

}

func loadFilesFromCache(files: [String], pluginWorkDirectory: String) throws {

    let start = CFAbsoluteTimeGetCurrent()

    for file in files {

        let name = URL(filePath: file).lastPathComponent

        guard let modificationDate = try FileManager.default.attributesOfItem(atPath: file)[.modificationDate] as? Date else { continue }

        let cached = URL(filePath: pluginWorkDirectory).appending(path: "cache/\(name).json")

        guard let cachedModificationDate = try? FileManager.default.attributesOfItem(atPath: cached.path())[.modificationDate] as? Date else { continue }

    }

    let cacheDirectoryURL = URL(filePath: pluginWorkDirectory).appending(path: "cache")

    for fileURL in try FileManager.default.contentsOfDirectory(at: cacheDirectoryURL, includingPropertiesForKeys: nil) where fileURL.pathExtension == "json" {
        let data = try Data(contentsOf: fileURL)
        let file = try JSONDecoder().decode(SwiftFileDeclaration.self, from: data)
        for type in file.types {

        }
    }

    let diff = CFAbsoluteTimeGetCurrent() - start

    print("warning: \(#function): \(diff) seconds")

}
