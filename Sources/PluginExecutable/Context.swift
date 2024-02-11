import Foundation
import PluginCore
import SwiftParser
import SwiftSyntax

struct DeploymentTarget {
    var iOS = ProcessInfo.processInfo.environment["IPHONEOS_DEPLOYMENT_TARGET"].flatMap(Double.init)
    var macOS = ProcessInfo.processInfo.environment["MACOSX_DEPLOYMENT_TARGET"].flatMap(Double.init)
}

final class Context {

    var files: [FileWrapper] = []

    private(set) lazy var types = TypesDeclCollector(files)

    private(set) lazy var views: [ViewDeclWrapper] = files.flatMap { file in
        TypesDeclCollector(file, kinds: [.struct]).structs.compactMap { node in
            if node.inheritanceClause?.inheritedTypes.contains(where: { ["App", "View"].contains($0.trimmedDescription) }) == true {
                return ViewDeclWrapper(decl: node, file: file)
            } else {
                return nil
            }
        }
    }

    private(set) lazy var modifiers: [String] = ModifiersDeclCollector(files).modifiers

    private(set) lazy var structs: [StructDeclSyntax] = types.structs

    private(set) lazy var enums: [EnumDeclSyntax] = types.enums

    private(set) lazy var classes: [ClassDeclSyntax] = types.classes

    private(set) lazy var actors: [ActorDeclSyntax] = types.actors

    private(set) lazy var extensions: [ExtensionDeclSyntax] = types.extensions

    private(set) var _paths: [String: [[ViewDeclWrapper]]] =  [:]
    private(set) var _loops: [String: [[ViewDeclWrapper]]] =  [:]

    var target = DeploymentTarget()
    
    var cache: Cache?
    
    var destinations: [String: [String]] = [:]

    convenience init(_ content: String) {
        self.init(FileWrapper(content))
    }

    init(_ file: FileWrapper) {

        self.files.append(file)

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            await loadPaths()
//            loadPathsSync()
        }

        semaphore.wait()

        SwiftUIModifiers.custom.formUnion(self.modifiers)

    }

    init(files: [String], cache: Cache? = nil) {
        
        self.cache = cache

        let start = CFAbsoluteTimeGetCurrent()

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            await load(files) // Task Group
            await loadPaths() // Task Group
        }

        semaphore.wait()

        SwiftUIModifiers.custom.formUnion(self.modifiers)

        let diff = CFAbsoluteTimeGetCurrent() - start

        print("warning: Context.init: \(diff) seconds")

    }

    private func load(_ files: [String]) async {

        let _files = await withTaskGroup(of: FileWrapper?.self, returning: [FileWrapper].self) { group in

            for file in files {
                group.addTask {
                    FileWrapper(path: file, cache: self.cache)!
                }
            }

            var _files = [FileWrapper]()

            for await result in group.compactMap({ $0 }) {
                _files.append(result)
            }

            return _files

        }

        self.files = _files

    }

    private func loadPaths() async {

        let views = self.views
        
        for view in views {
            destinations[view.name] = AllCallCollector(view.node, context: self).calls
        }

        await withTaskGroup(of: CallStackTrace.self) { group in

            for view in views {
                if !view.node.trimmedDescription.contains(anyOf: ["NavigationStack", "NavigationLink", "navigationDestination", "toolbar"]) {
                    continue
                }
                group.addTask {
                    CallStackTrace(view: view, context: self)
                }
            }

            for await stack in group {
                _paths[stack.name] = stack.paths
                _loops[stack.name] = stack.loops
            }

        }

    }

    func type(named name: String) -> TypeDeclSyntaxProtocol? {
        types.all.first {
            $0.name.text == name
        }
    }
    
    func _class(named name: String) -> ClassDeclSyntax? {
        if let _class = classes.first(where: { $0.name.text == name }) {
            return _class
        } else {
            return nil
        }
    }

    func extensions(of name: String) -> [ExtensionDeclSyntax] {
        return extensions.filter { $0.extendedType.as(IdentifierTypeSyntax.self)?.name.text == name }
    }

    func view(named name: String) -> ViewDeclWrapper? {
        return views.first {
            $0.node.name.trimmedDescription == name
        }
    }

    func paths(to view: ViewDeclWrapper) -> [[ViewDeclWrapper]] {
        if let _paths =  _paths[view.name] {
            return _paths
        } else {
            let stack = CallStackTrace(view: view, context: self)
            _paths[stack.name] = stack.paths
            _loops[stack.name] = stack.loops
            return stack.paths
        }
    }

//    func loops(_ view: ViewDeclWrapper) -> [[ViewDeclWrapper]] {
//        return _loops[view.name] ?? []
//    }

}
