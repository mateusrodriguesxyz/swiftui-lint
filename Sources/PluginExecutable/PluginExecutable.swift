import ArgumentParser
import PluginCore
import Foundation


@main
struct PluginExecutable: AsyncParsableCommand {

    @Argument()
    var pluginWorkDirectory: String = ""

    @Argument(parsing: .captureForPassthrough)
    var files: [String] = ["/Users/mateus/Downloads/MyBuildToolPlugin/Sources/PluginExecutable/SwiftUIView.swift"]

    func run() async throws {

        let start = CFAbsoluteTimeGetCurrent()

        loadCache()

        let context = Context(files: files)

//        for file in context.files {
//            print("warning: '\(file.name)' hasChanges: \(file.hasChanges ? "true" : "false")")
//        }

        let diagnosers: [any Diagnoser] = [
            ViewBuilderCountDiagnoser(),
            PropertyWrapperDiagnoser(),
            MissingDotModifierDiagnoser(),
            ListDiagnoser(),
            NavigationDiagnoser(),
            SheetDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser(),
            ContainerDiagnoser(),
        ]

//        try loadFilesFromCache(files: files, pluginWorkDirectory: pluginWorkDirectory)

//        try cache(context, pluginWorkDirectory: pluginWorkDirectory)

        await context.run(diagnosers)


        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: PluginExecutable: \(diff) seconds")
        
        try updateCache(context)

//        report(context)
        

        for (index, diagnostic) in Diagnostics.emitted.enumerated() {
            print("warning: diagnostic \(index) origin: \(diagnostic.origin)")
        }

//        for (index, diagnostic) in Diagnostics.emitted.enumerated() {
//            print("warning: diagnostic \(index) origin: \(diagnostic.origin)")
//        }

        if Diagnostics.emitted.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }

    }

    func loadCache() {
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        if let loadedCache = try? JSONDecoder().decode(Cache.self, from: Data(contentsOf: cacheURL)) {
            Cache.default = loadedCache
        }
    }

    func report(_ context: Context) {
        
//        print("warning: Project has \(context.views.count) views")
//
//        print("warning: Project has \(context.structs.count) structs")
//
//        print("warning: Project has \(context.enums.count) enums")
//
//        print("warning: Project has \(context.classes.count) classes")
//
//        let paths = context._paths.values.flatMap({ $0 })
//
//        print("warning: Project has \(paths.count) paths")

        print("warning: Plugin emmited \(Diagnostics.emitted.count) diagnostics")

    }

}

extension PluginExecutable {

    func updateCache(_ context: Context) throws {

        print("warning: \(URL(filePath: pluginWorkDirectory).path())")

        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")

        var cache = Cache.default ?? .init(modificationDates: [:])

        for file in context.files {
            cache.modificationDates[file.path] = file.modificationDate
        }

        cache.diagnostics = [:]

        for diagnostic in Diagnostics.emitted {
            guard let origin = diagnostic.origin else { continue }
            if let diagnostics = cache.diagnostics[origin] {
                cache.diagnostics[origin] = diagnostics + [diagnostic]
            } else {
                cache.diagnostics[origin] = [diagnostic]
            }
        }

        let encoder = JSONEncoder()

        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]

        let data = try encoder.encode(cache)

        try data.write(to: cacheURL)

        try? FileManager.default.createDirectory(at: URL(filePath: pluginWorkDirectory).appending(path: "cache"), withIntermediateDirectories: true)

        for file in context.files {

            let codable = file.codable(context)

            if !codable.types.isEmpty {

                let data = try encoder.encode(codable)

                let url = URL(filePath: pluginWorkDirectory).appending(path: "cache/\(file.name).json")

                do {
                    try data.write(to: url)
                } catch {
                    print("warning: \(error.localizedDescription)")
                }

            }

        }

    }

}

extension Context {

    func run(_ diagnosers: [Diagnoser]) async {

        await withTaskGroup(of: Void.self) { group in
            diagnosers.forEach { diagnoser in
                group.addTask {
                    
                    let elapsed = ContinuousClock().measure {
                        diagnoser.run(context: self)
                    }
//                    print("warning: \(Swift.type(of: diagnoser)): \(elapsed)")

                }
            }
        }

    }

}

struct Cache: Codable {

    static var `default`: Cache? = nil

    var modificationDates: [String: Date]
    var diagnostics: [String: [Diagnostic]] = [:]

    func diagnostics(_ origin: some Diagnoser, file: String) -> [Diagnostic] {
        return diagnostics[String(describing: type(of: origin))]?.filter { $0.location.file == file } ?? []
    }

}
