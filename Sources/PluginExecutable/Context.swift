import Foundation
import PluginCore
import SwiftParser
import SwiftSyntax

final class Context {

    var files: [FileWrapper] = []

    private(set) lazy var types = TypesDeclCollector(files)

    private lazy var _views: [String: ViewDeclWrapper] = Dictionary(uniqueKeysWithValues: views.map({ ($0.name, $0) }) )

    private(set) lazy var views: [ViewDeclWrapper] = files.flatMap { file in
        ViewCollector(source: file.source).views.map({ .init(decl: $0, file: file) })
    }

    private(set) lazy var structs: [StructDeclSyntax] = types.structs

    private(set) lazy var enums: [EnumDeclSyntax] = types.enums

    private(set) lazy var classes: [ClassDeclSyntax] = types.classes

    private(set) var _paths: [String: [[ViewDeclWrapper]]] =  [:]
    private(set) var _loops: [String: [[ViewDeclWrapper]]] =  [:]

    init() {
        self.files = []
    }

    init(files: [String]) {

        let start = CFAbsoluteTimeGetCurrent()

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            await load(files) // Task Group
            await loadPaths() // Task Group
        }

        semaphore.wait()

        let diff = CFAbsoluteTimeGetCurrent() - start

//        print("warning: Context.init: \(diff) seconds")

    }

    func load(_ files: [String]) async {

        let _files = await withTaskGroup(of: FileWrapper?.self, returning: [FileWrapper].self) { group in

            for file in files {
                group.addTask {
                    FileWrapper(path: file)!
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

    func loadPaths() async {

        let views = self.views

        let stacks = await withTaskGroup(of: CallStackTrace.self, returning: [CallStackTrace].self) { group in

            for view in views {
                if !view.contains(anyOf: ["NavigationStack", "NavigationLink", "navigationDestination"]) {
                    continue
                }
                group.addTask {
                    CallStackTrace(view: view, context: self)
                }
            }

            var stacks = [CallStackTrace]()

            for await stack in group {
                _paths[stack.name] = stack.paths
                _loops[stack.name] = stack.loops
//                stacks.append(result)
            }

            return stacks

        }

//        for stack in stacks {
//            _paths[stack.name] = stack.paths
//            _loops[stack.name] = stack.loops
//        }

    }

    func type(named name: String) -> SyntaxProtocol? {
        if let _struct = structs.first(where: { $0.name.text == name }) {
            return _struct
        }
        if let _enum = enums.first(where: { $0.name.text == name }) {
            return _enum
        }
        if let _class = classes.first(where: { $0.name.text == name }) {
            return _class
        }
        return nil
    }

    func view(named name: String) -> ViewDeclWrapper? {
        return views.first {
            $0.decl.name.trimmedDescription == name
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

    func loops(_ view: ViewDeclWrapper) -> [[ViewDeclWrapper]] {
        return _loops[view.name] ?? []
    }

}
