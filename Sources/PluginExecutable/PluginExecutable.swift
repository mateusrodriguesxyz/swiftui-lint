import ArgumentParser
import PluginCore
import Foundation


@main
struct PluginExecutable: AsyncParsableCommand {

    @Argument()
    var pluginWorkDirectory: String = "/Users/mateus/Desktop"

    @Argument(parsing: .captureForPassthrough)
    var files: [String] = []

    private var project: String? = "/Users/mateus/Downloads/PluginSandbox"

    func run() async throws {

        var files = files

        if files.isEmpty, let project {

            let enumerator = FileManager.default.enumerator(atPath: project)!

            for file in enumerator {
                if let file = file as? String, file.hasSuffix(".swift") {
                    if let url = URL(string: project)?.appending(path: file) {
                        files.append(url.path())
                    }
                }
            }

        }

        let start = CFAbsoluteTimeGetCurrent()

//        loadCache()

        let context = Context(files: files)

//        for file in context.files {
//            print("warning: \(file.name) hasChanges: \(file.hasChanges)")
//        }

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
        ]

        await context.run(diagnosers)

        try updateCache(context)

        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: PluginExecutable: \(diff) seconds")

//        report(context)

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

        print("warning: Project has \(context.views.count) views")

        print("warning: Project has \(context.structs.count) structs")

        print("warning: Project has \(context.enums.count) enums")

        print("warning: Project has \(context.classes.count) classes")

        print("warning: Plugin emmited \(Diagnostics.emitted.count) diagnostics")

    }

}

extension PluginExecutable {

    func updateCache(_ context: Context) throws {

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

    static var `default`: Cache? = nil

    var modificationDates: [String: Date]
    var diagnostics: [String: [Diagnostic]] = [:]

    func diagnostics(_ origin: some Diagnoser, file: String) -> [Diagnostic] {
        return diagnostics[String(describing: type(of: origin))]?.filter { $0.location.file == file } ?? []
    }

}
