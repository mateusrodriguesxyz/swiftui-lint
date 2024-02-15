import Foundation
import SwiftSyntax

final class PropertyWrapperDiagnoser2: Diagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {
        
        let views = context.views.map({ SwiftUIViewTypeDeclaration($0, context: context) })
        
        for view in views {
            
            let mutations = view.mutations
            
            func _class(named name: String) -> ClassDeclSyntax? {
                return context._class(named: name)
            }
            
            for property in view.properties {
                
                if property.attributes.contains("@State") {
                    
                    // MARK: Constant State
                    
                    if !mutations.contains(property.name) {
                        if let type = property.type?.baseType, _class(named: type) == nil {
                            warning("Variable '\(property.name)' was never mutated or used to create a binding; consider changing to 'let' constant", location: property.location)
                        }
                    }
                    
                    // MARK: Reference Type Wrapped Value
                    
                    if let type = property.type?.baseType, let _class = _class(named: type) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == false {
                            warning("Mark '\(type)' type with '@Observable' macro or, alternatively, use 'StateObject' property wrapper instead", location: property.location)
                        }
                    }
                    
                    // MARK: Non-Private State
                    
                    if !property.keywords.contains("private") {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", location: property.location)
                    }
                    
                }
                
                if property.attributes.contains("@Binding") {
                    if let type = property.type?.baseType, let _class = _class(named: type) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == true {
                            warning("Use 'Bindable' property wrapper instead", location: property.location)
                        }
                    }
                }
                
                if property.attributes.contains("@Bindable") {
                    if mutations.contains(property.name) == false {
                        warning("Property '\(property.name)' was never used to create a binding; consider removing 'Bindable' property wrapper", location: property.location)
                    }
                }
                
                // MARK: Non-Private StateObject
                
                if property.attributes.contains("@StateObject") {
                    
                    if !property.keywords.contains("private") {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", location: property.location)
                    }
                    
                }
                
                // MARK: Initialized ObservedObject
                
                if property.attributes.contains("@ObservedObject"), property.hasInitializer {
                    if property.isReferencingSingleton {
                        continue
                    }
                    warning("ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead", location: property.location)
                }
                
                // MARK: Missing Enviroment ObservableObject
                
                if property.attributes.contains("@EnvironmentObject") {
                    
                    func check(_ paths: [[ViewDeclWrapper]]) -> Bool {
                        
                        for path in paths {
                            
                            for (view, next) in path.pairs() {
                                
                                for environmentObjectModifier in view.environmentObjectModifiers(context) {
                                    guard property.type?.description == environmentObjectModifier.type else { continue }
                                    if environmentObjectModifier.targets.contains(next.name) {
                                        return true
                                    }
                                }
                                
                            }
                            
                        }
                        
                        return false
                        
                    }
                    
                    if check(context.paths(to: context._views[view.name]!)) == false {
                        warning("Insert object of type '\(property.type!.baseType)' in environment with 'environmentObject' up in the hierarchy", location: property.location)
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
}
