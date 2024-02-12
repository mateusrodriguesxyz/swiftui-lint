import Foundation
import SwiftSyntax

final class PropertyWrapperDiagnoser: Diagnoser {

    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {

        for view in context.views {
                        
//            lazy var mutations = MaybeMutationCollector(view.node).targets
            
            lazy var mutations: [String] = {
                if view.file.hasChanges {
                    let targets = MaybeMutationCollector(view.node).targets
                    context.cache?.mutations[view.name] = targets
                    return targets
                } else {
                    if let mutations = context.cache?.mutations[view.name] {
                        return mutations
                    } else {
                        let targets = MaybeMutationCollector(view.node).targets
                        context.cache?.mutations[view.name] = targets
                        return targets
                    }
                }
            }()
            
            func type(of property: PropertyDeclWrapper) -> String? {
                return property._type(context)?.baseType
            }
            
            func _class(named name: String) -> ClassDeclSyntax? {
                return context._class(named: name)
            }
            
            for property in view.properties {

                if property.attributes.contains("@State") {

                    // MARK: Constant State

                    if !mutations.contains(property.name) {
                        if let type = type(of: property), _class(named: type) == nil {
                            warning("Variable '\(property.name)' was never mutated or used to create a binding; consider changing to 'let' constant", node: property.decl, file: view.file)
                        }
                    }

                    // MARK: Reference Type Wrapped Value

                    if let type = type(of: property), let _class = _class(named: type) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == false {
                            warning("Mark '\(type)' type with '@Observable' macro or, alternatively, use 'StateObject' property wrapper instead", node: property.decl, file: view.file)
                        }
                    }

                    // MARK: Non-Private State

                    if !property.decl.modifiers.contains(where: { $0.name.text == "private" }) {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.decl, file: view.file)
                    }

                }
                
                if property.attributes.contains("@Binding") {
                    if let type = type(of: property), let _class = _class(named: type) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == true {
                            warning("Use 'Bindable' property wrapper instead", node: property.decl, file: view.file)
                        }
                    }
                }
                
                if property.attributes.contains("@Bindable") {
                    if BindableReferenceCollector(view.node).targets.contains(property.name) == false {
                        warning("Property '\(property.name)' was never used to create a binding; consider removing 'Bindable' property wrapper", node: property.decl, file: view.file)
                    }
                }

                if property.attributes.contains("@StateObject") {

                    // MARK: Non-Private State

                    if !property.decl.modifiers.contains(where: { $0.name.text == "private" }) {
                        warning("Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.decl, file: view.file)
                    }

                }

                // MARK: Initialized ObservedObject

                if property.attributes.contains("@ObservedObject"), property.hasInitializer {
                    if property.isReferencingSingleton(context: context) {
                        continue
                    }
                    warning("ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead", node: property.decl, file: view.file)
                }

                if property.attributes.contains("@EnvironmentObject") {
                    
                    func check(_ paths: [[ViewDeclWrapper]]) -> Bool {

//                        let _view = view.name

//                        print("Paths to '\(view.name)': \(paths.count) ")

                        for path in paths {

                            for (view, next) in path.pairs() {
                                for environmentObjectModifier in ModifierCollector(modifier: "environmentObject", view.node).matches {

//                                    warning("⭐️", node: environmentObjectModifier.decl, file: view.file)

//                                    warning("environmentObject found in '\(_view)' path", node: environmentObjectModifier.decl, file: view.file)

                                    guard let object = environmentObjectModifier.expression?.trimmedDescription else { continue }

                                    guard let _property = view.property(named: object)  else { continue }

                                    guard property.type == _property.type else { continue }

                                    guard let content = environmentObjectModifier.content else { continue }

                                    for reference in ReferencesCollector(content).references where reference.baseName.text == next.name {
                                        return true
                                    }
                                }
                            }

                        }

                        return false

                    }

                    // MARK: Missing Enviroment ObservableObject

                    if check(context.paths(to: view)) == false {
                        warning("Insert object of type '\(property.baseType(context)!)' in environment with 'environmentObject' up in the hierarchy", node: property.decl, file: view.file)
                    }

                }

            }

        }
    }

}
