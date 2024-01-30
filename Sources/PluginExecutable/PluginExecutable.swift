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
//            StacksDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser(),
            ContainerDiagnoser(),
//            _PrintDiagnoser(),
        ]

//        try loadFilesFromCache(files: files, pluginWorkDirectory: pluginWorkDirectory)

//        try cache(context, pluginWorkDirectory: pluginWorkDirectory)

        await context.run(diagnosers)

        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: PluginExecutable: \(diff) seconds")

//        report(context)
        

        try updateCache(context)

        for diagnostic in Diagnostics.emitted {
            print("warning: diagnostic origin: \(diagnostic.origin)")
        }

        if Diagnostics.emitted.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }

    }

    func loadCache() {
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        Cache.default = (try? JSONDecoder().decode(Cache.self, from: Data(contentsOf: cacheURL))) ?? .init(modificationDates: [:])
    }

    func report(_ context: Context) {
        
        print("warning: Project has \(context.views.count) views")

        print("warning: Project has \(context.structs.count) structs")

        print("warning: Project has \(context.enums.count) enums")

        print("warning: Project has \(context.classes.count) classes")

        let paths = context._paths.values.flatMap({ $0 })

        print("warning: Project has \(paths.count) paths")

        print("warning: Plugin emmited \(Diagnostics.emitted.count) diagnostics")

    }

}

extension PluginExecutable {

    func updateCache(_ context: Context) throws {

        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")

        var cache = Cache.default

        for file in context.files {
            cache.modificationDates[file.path] = file.modificationDate
        }

        let encoder = JSONEncoder()

        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(cache)

        try data.write(to: cacheURL)

        print("warning: \(cacheURL.path())")

    }

}

extension Context {

//    func run(_ diagnosers: [Diagnoser]) {
//
//        let semaphore = DispatchSemaphore(value: 0)
//
//        Task {
//
//            defer { semaphore.signal() }
//
//            await withTaskGroup(of: Void.self) { group in
//                diagnosers.forEach { diagnoser in
//                    group.addTask {
//
//                        let elapsed = ContinuousClock().measure {
//                            diagnoser.run(context: self)
//                        }
//                        print("warning: \(Swift.type(of: diagnoser)): \(elapsed)")
//
////                        diagnoser.run(context: self)
//
//                    }
//                }
//            }
//
//        }
//
//        semaphore.wait()
//    }

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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

public struct Cache: Codable {

    static var `default` = Cache(modificationDates: [:])

    public var modificationDates: [String: Date]

}
