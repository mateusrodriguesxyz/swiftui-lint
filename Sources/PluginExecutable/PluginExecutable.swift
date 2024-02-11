import ArgumentParser
import PluginCore
import Foundation

@main
struct PluginExecutable: AsyncParsableCommand {

    @Argument()
    var pluginWorkDirectory: String
    
    @Argument(parsing: .captureForPassthrough)
    var files: [String] = []

    func run() async throws {
        
        let start = CFAbsoluteTimeGetCurrent()

        let context = Context(files: files, cache: loadedCache())

        print("warning: Changed Files: \(context.files.filter(\.hasChanges).count)")

        let diagnosers: [any Diagnoser] = [
            ViewBuilderCountDiagnoser(),
            MissingDotModifierDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser(),
            ContainerDiagnoser(),
            ListDiagnoser(),
            NavigationDiagnoser(),
            PropertyWrapperDiagnoser(),
            SheetDiagnoser(),
            ScrollableDiagnoser(),
        ]

        await context.run(diagnosers)
        
        let diagnostics = diagnosers.flatMap(\.diagnostics)
        
        for diagnostic in diagnostics {
            diagnostic()
        }

        try updateCache(context, diagnostics: diagnostics)

        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: PluginExecutable: \(diff) seconds")

//        report(context)
        
        let modelOnlyFiles = context.files.filter { file in
            !TypesDeclCollector(file).structs.contains { node in
                node.inheritanceClause?.inheritedTypes.contains(where: { ["App", "View"].contains($0.trimmedDescription) }) == true
            }
        }
        
        print("warning: Model Only Files: \(modelOnlyFiles.count)/\(context.files.count)")
    

        if diagnostics.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }

    }

    func loadedCache() -> Cache? {
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        return try? JSONDecoder().decode(Cache.self, from: Data(contentsOf: cacheURL))
    }

//    func report(_ context: Context) {
//
//        print("warning: Project has \(context.views.count) views")
//
//        print("warning: Project has \(context.structs.count) structs")
//
//        print("warning: Project has \(context.enums.count) enums")
//
//        print("warning: Project has \(context.classes.count) classes")
//
//        print("warning: Plugin emmited \(Diagnostics.emitted.count) diagnostics")
//
//    }

}

extension PluginExecutable {

    func updateCache(_ context: Context, diagnostics: [Diagnostic]) throws {

        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")

        var cache = context.cache ?? .init()

        for file in context.files {
            cache.modificationDates[file.path] = file.modificationDate
        }

        cache.diagnostics = [:]

        for diagnostic in diagnostics {
            let origin = diagnostic.origin
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

//        try? FileManager.default.createDirectory(at: URL(filePath: pluginWorkDirectory).appending(path: "cache"), withIntermediateDirectories: true)
//
//        for file in context.files where file.hasChanges {
//
//            print("warning: caching '\(file.name)'")
//
//            let codable = file.codable(context)
//
//            if !codable.types.isEmpty {
//
//                let data = try encoder.encode(codable)
//
//                let url = URL(filePath: pluginWorkDirectory).appending(path: "cache/\(file.name).json")
//
//                do {
//                    try data.write(to: url)
//                } catch {
//                    print("warning: \(error.localizedDescription)")
//                }
//
//            }
//
//        }

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
                    print("warning: \(Swift.type(of: diagnoser)): \(elapsed)")

                }
            }
        }

    }

}

struct Cache: Codable {
    
    typealias FilePath = String

    var modificationDates: [FilePath: Date] = [:]
    
    var diagnostics: [FilePath: [Diagnostic]] = [:]

    func diagnostics(_ origin: some Diagnoser, file: String) -> [Diagnostic] {
        return diagnostics[String(describing: type(of: origin))]?.filter { $0.location.file == file } ?? []
    }

}
