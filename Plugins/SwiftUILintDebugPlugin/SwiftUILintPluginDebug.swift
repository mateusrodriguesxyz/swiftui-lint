import PackagePlugin
import Foundation

@main
struct SwiftUILintDebugPlugin: BuildToolPlugin {

    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        return []
    }

}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftUILintDebugPlugin: XcodeBuildToolPlugin {

    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        var files = target.inputFiles.filter { $0.path.extension == "swift" }.map(\.path.string)

        do {
            
            let directory = URL(string: context.xcodeProject.directory.string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!

            for url in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
                guard FileManager.default.fileExists(atPath: url.appending(path: "Package.swift").path, isDirectory: nil) else { continue }
                let enumerator = FileManager.default.enumerator(atPath: url.path)!
                for file in enumerator {
                    if let file = file as? String, file.hasSuffix(".swift") {
                        files.append(url.appending(path: file).path)
                    }
                }
            }

        }

        return [
            .buildCommand(
                displayName: "SwiftUI Lint",
                executable: try context.tool(named: "SwiftUILintExecutable").path,
                arguments: [context.pluginWorkDirectory] + files,
                outputFiles: []
            )
        ]

    }
}

#endif
