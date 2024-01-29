import ArgumentParser
import PluginCore
import Foundation

@main
struct PluginExecutable: AsyncParsableCommand {

    @Argument()
    var pluginWorkDirectory: String = ""

    @Argument(parsing: .captureForPassthrough)
    var files: [String] = []

    func run() async throws {

//        print("warning: \(pluginWorkDirectory)")

        let start = CFAbsoluteTimeGetCurrent()

        let context = Context(files: files)

        let diagnosers: [any Diagnoser] = [
            ViewBuilderCountDiagnoser(),
            PropertyWrapperDiagnoser(),
            MissingDotModifierDiagnoser(),
            ListDiagnoser(),
            NavigationDiagnoser(),
            SheetDiagnoser(),
            StacksDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser()
        ]

//        try loadFilesFromCache(files: files, pluginWorkDirectory: pluginWorkDirectory)

//        try cache(context, pluginWorkDirectory: pluginWorkDirectory)

        await context.run(diagnosers)

        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: Custom SwiftUI Modifiers: \(context.modifiers.formatted())")

        print("warning: PluginExecutable: \(diff) seconds")


//        report(context)

        if Diagnostics.emitted.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }

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
