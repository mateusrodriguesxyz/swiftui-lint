import Foundation
import SwiftSyntax

final class PropertyWrapperDiagnoser: Diagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {
        
        for view in context.views {
            
            lazy var mutations = MaybeMutationCollector(view.node)
            
            func type(of property: PropertyDeclWrapper) -> String? {
                return property._type(context)?.baseType
            }
            
            for property in view.properties {
                                
                if property.attributes.contains("@State") {
                    
                    // MARK: Constant State
                    
                    if !mutations.targets.contains(property.name) {
                        if let type = type(of: property), context._class(named: type) == nil {
                            warning("Variable '\(property.name)' was never mutated or used to create a binding; consider changing to 'let' constant", node: property.node, file: view.file)
                        }
                    }
                    
                    // MARK: Reference Type Wrapped Value
                    
                    if let type = type(of: property), let _class = context._class(named: type) {
                        if _class.attributes.trimmedDescription.contains(anyOf: "@Observable", "@Model") == false {
                            if context.target.iOS ?? 9999 >= 17.0 {
                                warning("Mark '\(type)' type with '@Observable' macro", node: property.node, file: view.file)
                            } else {
                                warning("Use 'StateObject' property wrapper instead", node: property.node, file: view.file)

                            }
                        }
                    }
                    
                    // MARK: Non-Private State
                    
                    if !property.isPrivate {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.node, file: view.file)
                    }
                    
                }
                
                if property.attributes.contains("@Binding") {
                    if !mutations.targets.contains(property.name) {
                        if let type = type(of: property), context._class(named: type) == nil {
                            warning("Variable '\(property.name)' was never mutated or used as binding; consider changing to 'let' constant", node: property.node, file: view.file)
                        }
                    }
                    if let type = type(of: property), let _class = context._class(named: type) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == true {
                            warning("Use 'Bindable' property wrapper instead", node: property.node, file: view.file)
                        }
                    }
                }
                
                if property.attributes.contains("@Bindable") {
                    if mutations.bindings.contains(property.name) == false {
                        warning("Property '\(property.name)' was never used to create a binding; consider removing 'Bindable' property wrapper", node: property.node, file: view.file)
                    }
                }
                
                // MARK: Non-Private StateObject
                
                if property.attributes.contains("@StateObject") {
                    if !property.isPrivate {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.node, file: view.file)
                    }
                    
                }
                
                // MARK: Initialized ObservedObject
                
                if property.attributes.contains("@ObservedObject"), property.hasInitializer {
                    if property.isReferencingSingleton(context: context) {
                        continue
                    }
                    warning("ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead", node: property.node, file: view.file)
                }
                
                // MARK: Missing Enviroment Object
                
                guard let type = property.type else {
                    continue
                }
                
                if property.attributes.contains("@EnvironmentObject") {
                    if check(context.paths(to: view), modifier: "environmentObject") == false {
                        warning("Insert object of type '\(property.baseType(context)!)' in environment using 'environmentObject' modifier up in the hierarchy", node: property.node, file: view.file)
                    }
                }
                
                if property.attribute("@Environment") != nil {
                    if check(context.paths(to: view), modifier: "environment") == false {
                        warning("Insert object of type '\(type)' in environment using 'environment' modifier up in the hierarchy", node: property.node, file: view.file)
                    }
                }
                
                func check(_ paths: [[ViewDeclWrapper]], modifier: String) -> Bool {
                    
                    var environmentObjectIsValid = false
                    
                    for path in paths {
                        
//                        warning(path.description, node: property.node, file: view.file)
                                                
                        var environmentObjectIsInNavigationStack = false
                        
                        var nextIsInNavigationStack = false
                        
                        var environmentIsInjected = false
                                                                                
                        for (view, next) in path.pairs() {
                            
                            if !AnyCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], from: view.node).calls.isEmpty, environmentIsInjected {
                                environmentObjectIsInNavigationStack = true
                            }

                            if let presenter = ViewPresenterCollector(view.node).matches.first(where: { $0.kind == .navigation }) {
                                if presenter.node.trimmedDescription.contains(next.name) || presenter.destination?.trimmedDescription.contains(next.name) == true {
                                    nextIsInNavigationStack = true
                                }
                            }
                            
                            for environmentObjectModifier in view.environmentObjectModifiers(context) {
                                guard type == environmentObjectModifier.type else { continue }
                                if environmentObjectModifier.targets.contains(next.name) {
                                    environmentIsInjected = true
                                    if let navigation = AnyCallCollector(["NavigationView", "NavigationStack",  "NavigationSplitView"], from: view.node).calls.first(where: { $0.trimmedDescription.contains(next.name) }) {
                                        if let _ = AllAppliedModifiersCollector(navigation).matches(modifier).first {
                                            environmentObjectIsInNavigationStack = true
                                        }
                                    }
                                    if next == path.first {
                                        return environmentIsInjected
                                    }
                                }
                            }
                            
                        }
                                                
                        if environmentIsInjected {
                            if nextIsInNavigationStack {
                                environmentObjectIsValid = environmentObjectIsInNavigationStack
                            } else {
                                environmentObjectIsValid = true
                            }
                        }
                        
                    }
                    
                    return environmentObjectIsValid
                    
                }

                                
            }
            
            for match in ClosureBindingCollector(view.node).matches { 
                let name = match.name.text
                if name.starts(with: "$"), !mutations.contains(name) {
                    warning("Binding '\(name)' was never used", node: match, file: view.file)
                }
                
            }
            
        }
    }
    
}
