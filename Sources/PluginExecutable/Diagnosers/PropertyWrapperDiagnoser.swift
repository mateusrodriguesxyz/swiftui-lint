import Foundation

struct PropertyWrapperDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            lazy var mutations = MaybeMutationCollector(view.node).targets

            for property in view.properties {

//                let type = property._type(context, baseType: view.node)
//
//                if type == nil {
//                    Diagnostics.emit(.warning, message: "unknown type", node: property.decl, file: view.file)
//                }

                if property.attributes.isEmpty { continue }

                if property.attributes.contains("@State") {

                    // MARK: Constant State

                    if !mutations.contains(property.name) {
                        if let type = property.baseType(context), !context.classes.contains(where: { $0.name.text == type }) {
                            Diagnostics.emit(.warning, message: "Variable '\(property.name)' was never mutated or used to create a binding; consider changing to 'let' constant", node: property.decl, file: view.file)
                        }
                    }

                    // MARK: Reference Type Wrapped Value

                    if !context.classes.isEmpty, let type = property.baseType(context), let _class = context.classes.first(where: { $0.name.text == type }) {
                        if _class.attributes.trimmedDescription.contains("@Observable") == false {
                            Diagnostics.emit(.warning, message: "Mark '\(type)' type with '@Observable' macro or, alternatively, use 'StateObject' property wrapper instead", node: property.decl, file: view.file)
                        }
                    }

                    // MARK: Non-Private State

                    if !property.decl.modifiers.contains(where: { $0.name.text == "private" }) {
                        Diagnostics.emit(.warning, message: "Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.decl, file: view.file)
                    }

                }

                if property.attributes.contains("@StateObject") {

                    // MARK: Non-Private State

                    if !property.decl.modifiers.contains(where: { $0.name.text == "private" }) {
                        Diagnostics.emit(.warning, message: "Variable '\(property.name)' should be declared as private to prevent unintentional memberwise initialization", node: property.decl, file: view.file)
                    }

                }

                // MARK: Initialized ObservedObject

                if property.attributes.contains("@ObservedObject"), property.hasInitializer {
                    if property.isReferencingSingleton(context: context) {
                        continue
                    }
                    Diagnostics.emit(.warning, message: "ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead", node: property.decl, file: view.file)
                }

                if property.attributes.contains("@EnvironmentObject") {

                    func check(_ paths: [[ViewDeclWrapper]]) -> Bool {

//                        let _view = view.name

//                        print("Paths to '\(view.name)': \(paths.count) ")

                        for path in paths {

                            for (view, next) in path.pairs() {
                                for environmentObjectModifier in ModifierCollector(modifier: "environmentObject", view.node).matches {

//                                    Diagnostics.emit(.warning, message: "⭐️", node: environmentObjectModifier.decl, file: view.file)

//                                    Diagnostics.emit(.warning, message: "environmentObject found in '\(_view)' path", node: environmentObjectModifier.decl, file: view.file)

                                    guard let object = environmentObjectModifier.expression?.trimmedDescription else { continue }

                                    guard let _property = view.property(named: object)  else { continue }

                                    guard property.type == _property.type else { continue }

                                    guard let content = environmentObjectModifier.content else { continue }

                                    for reference in ReferencesCollector(content).references {
                                        if reference.baseName.text == next.name {
                                            return true
                                        }
                                    }
                                }
                            }

                        }

                        return false

                    }

                    // MARK: Missing Enviroment ObservableObject

                    if check(context.paths(to: view)) == false {
                        Diagnostics.emit(.warning, message: "Insert object of type '\(property.baseType!)' in environment with 'environmentObject' up in the hierarchy", node: property.decl, file: view.file)
                    }

                }

            }

        }
    }

}
