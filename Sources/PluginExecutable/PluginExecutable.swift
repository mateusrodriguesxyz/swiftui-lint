import ArgumentParser
import Foundation

@main
struct PluginExecutable: AsyncParsableCommand {
    
    @Argument()
    var pluginWorkDirectory: String = ""
    
    @Argument(parsing: .captureForPassthrough)
    var files: [String] = []
    
    func run() async throws {
        
        var cache: Cache?
        
        await measure("Cache Loading") {
            cache = loadedCache()
        }
        
        try await measure("PluginExecutable.run") {
            try await _run(cache: cache)
        }
    }
    
    func _run(cache: Cache?) async throws {
                
        let diagnosers: [any Diagnoser] = [
            ViewBuilderCountDiagnoser(),
            MissingDotModifierDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser(),
            ContainerDiagnoser(),
            ListDiagnoser(),
            SheetDiagnoser(),
            ScrollableDiagnoser(),
            PropertyWrapperDiagnoser(),
            NavigationDiagnoser(),
        ]
        
        if let cache, files.allSatisfy({ cache.fileHasChanges($0) == false }) {
            let diagnostics = cache.diagnostics.values.flatMap({ $0 })
            try emit(diagnostics)
            return
        }
        
        let context = await Context(files: files, cache: cache)
        
        print("warning: Files: \(context.files.count)")
        
        print("warning: Changed Files: \(context.files.filter(\.hasChanges).count)")
        
        let diagnostics = await context.run(diagnosers)
        
        try await measure("Caching") {
            try await updateCache(context, diagnostics: diagnostics)
        }
        
        
        try emit(diagnostics)
        
    }
    
    func emit(_ diagnostics: [Diagnostic]) throws {
        for diagnostic in diagnostics {
            diagnostic()
        }
        if diagnostics.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }
    }
    
}

extension PluginExecutable {
    
    func loadedCache() -> Cache? {
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        return try? JSONDecoder().decode(Cache.self, from: Data(contentsOf: cacheURL))
    }
    
    func updateCache(_ context: Context, diagnostics: [Diagnostic]) async throws {
        
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        
        var cache = context.cache ?? .init()
        
        //        if cache.types.isEmpty {
        //            cache.types = context.files.flatMap { file in
        //                TypesDeclCollector(file).all
        //                    .map { node in
        //                        SwiftModelTypeDeclaration(node, file: file, context: context)
        //                    }
        //            }
        //        }
        
        for file in context.files {
            cache.modificationDates[file.path] = file.modificationDate
        }
        
        cache.destinations = context.destinations
        
        cache.diagnostics = [:]
        
        for diagnostic in diagnostics {
            let origin = diagnostic.origin
            cache.diagnostics[origin] = [diagnostic]
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
        
    }
    
}

extension Context {
    
    func run(_ diagnosers: [Diagnoser]) async -> [Diagnostic] {
        
        await withTaskGroup(of: Void.self) { group in
            diagnosers.forEach { diagnoser in
                group.addTask {
                    await measure("\(Swift.type(of: diagnoser))") {
                        diagnoser.run(context: self)
                    }
                }
            }
        }
        
        return diagnosers.flatMap(\.diagnostics)
        
    }
    
}

func measure(_ label: String, work: () async throws -> Void) async rethrows {
    let elapsed = try await ContinuousClock().measure {
        try await work()
    }
    print("warning: \(label): \(elapsed)")
}
