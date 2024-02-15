import Foundation
import SwiftParser
import SwiftSyntax

struct DeploymentTarget {
    var iOS = ProcessInfo.processInfo.environment["IPHONEOS_DEPLOYMENT_TARGET"].flatMap(Double.init)
    var macOS = ProcessInfo.processInfo.environment["MACOSX_DEPLOYMENT_TARGET"].flatMap(Double.init)
}

final class Context {
    
    private(set) var files: [FileWrapper] = []
    
    private(set) lazy var types = TypesDeclCollector(files)
    
    private(set) lazy var views: [ViewDeclWrapper] = files.flatMap { file in
        TypesDeclCollector(file, kinds: [.struct]).structs
            .filter {
                $0.inheritanceClause?.inheritedTypes.contains(where: { ["App", "View"].contains($0.trimmedDescription) }) == true
            }
            .map {
                ViewDeclWrapper(node: $0, file: file)
            }
//            .compactMap { node in
//                if node.inheritanceClause?.inheritedTypes.contains(where: { ["App", "View"].contains($0.trimmedDescription) }) == true {
//                    return ViewDeclWrapper(decl: node, file: file)
//                } else {
//                    return nil
//                }
//            }
    }
    
    private(set) lazy var _views: [String: ViewDeclWrapper] = Dictionary(uniqueKeysWithValues: views.map({ ($0.name, $0) }))
    
    private(set) lazy var modifiers: [String] = ModifiersDeclCollector(files).modifiers
    
    private(set) var paths: [String: [[ViewDeclWrapper]]] =  [:]
//    private(set) var loops: [String: [[ViewDeclWrapper]]] =  [:]
    
    private(set) var destinations: [String: [String]] = [:]
    
    var cache: Cache?
    
    var target = DeploymentTarget()
    
    convenience init(_ content: String) {
        self.init(FileWrapper(content))
    }
    
    init(_ file: FileWrapper, cache: Cache? = nil) {
        
        self.cache = cache
        
        self.files.append(file)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            defer { semaphore.signal() }
            await loadPaths()
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
        
        if let cachedDestinations = cache?.destinations {
            destinations = cachedDestinations
            for view in views where view.file.hasChanges {
                destinations[view.name] = DestinationCollector(view.node, context: self).destinations
            }
        } else {
            for view in views {
                destinations[view.name] = DestinationCollector(view.node, context: self).destinations
            }
        }
        
        await withTaskGroup(of: PathsBuilder.self) { group in
            
            for view in views {
                if !view.node.trimmedDescription.contains(anyOf: ["NavigationStack", "NavigationLink", "navigationDestination", "toolbar"]) {
                    continue
                }
                group.addTask {
                    PathsBuilder(view: view, context: self)
                }
            }
            
            for await stack in group {
                paths[stack.name] = stack.paths
//                loops[stack.name] = stack.loops
            }
            
        }
        
    }
    
    subscript<T: TypeDeclSyntaxProtocol>(dynamicMember keyPath: KeyPath<TypesDeclCollector, [T]>) -> [T] {
        types[keyPath: keyPath]
    }
    
    func type(named name: String) -> TypeDeclSyntaxProtocol? {
        types.all.first {
            $0.name.text == name
        }
    }
    
    func _class(named name: String) -> ClassDeclSyntax? {
        if let _class = types.classes.first(where: { $0.name.text == name }) {
            return _class
        } else {
            return nil
        }
    }
    
    func extensions(of name: String) -> [ExtensionDeclSyntax] {
        return types.extensions.filter { $0.extendedType.as(IdentifierTypeSyntax.self)?.name.text == name }
    }
    
    //    func view(named name: String) -> ViewDeclWrapper? {
    //        return views.first {
    //            $0.node.name.trimmedDescription == name
    //        }
    //    }
    
    func paths(to view: ViewDeclWrapper) -> [[ViewDeclWrapper]] {
        if let _paths =  paths[view.name] {
            return _paths
        } else {
            let stack = PathsBuilder(view: view, context: self)
            paths[stack.name] = stack.paths
//            loops[stack.name] = stack.loops
            return stack.paths
        }
    }
    
    //    func loops(_ view: ViewDeclWrapper) -> [[ViewDeclWrapper]] {
    //        return _loops[view.name] ?? []
    //    }
    
}
