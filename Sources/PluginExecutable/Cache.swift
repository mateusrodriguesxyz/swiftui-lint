//
//  File.swift
//
//
//  Created by Mateus Rodrigues on 26/01/24.
//

import SwiftSyntax
import Foundation

extension FileWrapper {

    func codable(_ context: Context) -> SwiftFileDeclaration {

        func _properties(of node: SyntaxProtocol) -> [SwiftPropertyDeclaration] {
            return node.properties(context).map({ SwiftPropertyDeclaration($0, file: self, context: context) })
//            PropertyCollector(node).properties.map({ SwiftPropertyDeclaration($0, file: self, context: context) })
        }

        var types = [SwiftTypeDeclaration]()

        let collector = TypesDeclCollector(self)

        func additionalProperties(of name: String) -> [SwiftPropertyDeclaration] {

            var properties = [SwiftPropertyDeclaration]()

            var incompleteProperties = [SwiftPropertyDeclaration]()

            for _extension in collector.extensions {
                if _extension.extendedType.as(IdentifierTypeSyntax.self)?.name.text == name  {
                    let additionalProperties =  _properties(of: _extension)
                    for property in additionalProperties {
                        if property.type == nil {
                            incompleteProperties.append(property)
                        } else {
                            properties.append(property)
                        }
                    }
                }
            }

//            for property in incompleteProperties {
//
//                var type: TypeWrapper?
//
//                let description = property.description
//                    .replacingOccurrences(of: " ", with: "")
//                    .replacingOccurrences(of: "\n", with: "")
//
//                if let match = description.firstMatch(of: #/\[(.*?)\]/#)?.output {
//                    if let element = match.1.components(separatedBy: ",").first {
//                        if let baseType = properties.first(where: { $0.name == element })?.type?.baseType {
//                            type = .array(baseType)
//                        }
//                    }
//                }
//
//                if type == nil {
//                    print("warning: \(self.name), \(property.name) ❌")
//                } else {
//                    print("warning: \(self.name), \(property.name) ✅")
//                }
//
//                properties.append(property.type(type))
//
//            }

            return properties

        }

        collector.structs.forEach { node in
            if node.inheritanceClause?.trimmedDescription.contains(anyOf: ["View", "App", "PreviewProvider"]) == true {
                return
            }
            let name = node.name.text
            var properties = _properties(of: node)
//            properties.append(contentsOf: additionalProperties(of: name))
            for property in properties {
                if property.type == nil {
                    print("warning: ❌ \(self.name), '\(property.name)' type is nil")
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._struct, name: name, properties: properties, cases: []))
        }

        collector.classes.forEach { node in
            let name = node.name.text
            var properties = _properties(of: node)
//            properties.append(contentsOf: additionalProperties(of: name))
            for property in properties {
                if property.type == nil {
                    Diagnostics.emit(.warning, message: "❌ \(self.name), '\(property.name)' type is nil", location: property.location)
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._class, name: name, properties: properties, cases: []))
        }

        collector.actors.forEach { node in
            let name = node.name.text
            var properties = _properties(of: node)
//            properties.append(contentsOf: additionalProperties(of: name))
            for property in properties {
                if property.type == nil {
                    print("warning: ❌ \(self.name), '\(property.name)' type is nil")
                }
            }
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._actor, name: name, properties: properties, cases: []))
        }

        collector.enums.forEach { node in
            let name = node.name.text
            let properties = _properties(of: node)
            let cases = CaseCollector(node).matches
            types.append(SwiftTypeDeclaration(location: location(of: node), kind: ._enum, name: name, properties: properties, cases: cases))
        }

        return SwiftFileDeclaration(name: name, path: path, types: types)

    }

}

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

    let _properties: [String]

    let cases: [String]

    enum CodingKeys: String, CodingKey {
        case location
        case name = "_0_name"
        case kind = "_1_kind"
        case properties
        case _properties = "_3_properties"
        case cases
    }

    init(location: SourceLocation, kind: Kind, name: String, properties: [SwiftPropertyDeclaration], cases: [String]) {
        self.location = location
        self.kind = kind
        self.name = name
        self.properties = properties
        self._properties = properties.map(\.name)
        self.cases = cases
    }

}

struct SwiftPropertyDeclaration: Codable {

    let location: SourceLocation

    let description: String

    let name: String

    let attributes: Set<String>

    let keywords: Set<String>

    let hasInitializer: Bool

    var type: TypeWrapper?

}

extension SwiftPropertyDeclaration {

    func type(_ type: TypeWrapper?) -> Self {
        var copy = self
        copy.type = type
        return copy
    }

}

extension SwiftPropertyDeclaration {

    init(_ property: PropertyDeclWrapper, file: FileWrapper, context: Context) {

        let node = property.node.as(VariableDeclSyntax.self)!

        self.location = file.location(of: node)
        self.description = property.node.trimmedDescription
        self.name = property.name
        self.attributes = property.attributes
        self.keywords = Set(node.modifiers.map(\.name.text) + [node.bindingSpecifier.text])
        self.hasInitializer = property.hasInitializer
        self.type = property._type(context)
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
            let properties = PropertyCollector(node).properties.map({ SwiftPropertyDeclaration($0, file: file, context: context) })

            types.append(SwiftTypeDeclaration(location: file.location(of: node), kind: ._struct, name: name, properties: properties, cases: []))

        }

        let _enums = TypesDeclCollector(file).enums

        _enums.forEach { node in
            let name = node.name.text
            let properties = PropertyCollector(node).properties.map({ SwiftPropertyDeclaration($0, file: file, context: context) })
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
