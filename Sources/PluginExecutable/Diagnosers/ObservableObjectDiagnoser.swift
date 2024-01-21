struct ObservableObjectDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            for property in view.properties {

                // MARK: Initialized ObservedObject

                if property.attributes.contains("@ObservedObject"), property.hasInitializer {
                    Diagnostics.emit(.warning, message: "ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead", node: property.decl, file: view.file)
                }

                if property.attributes.contains("@EnvironmentObject") {

//                    for path in context.paths(to: view) {
//                        for (view, next) in zip(path, path.dropFirst()) {
//                            if let environmentObjectModifier = ModifierCollector(modifier: "environmentObject", view.decl).match, let content = environmentObjectModifier.content {
//                                for reference in ReferencesCollector(content).references {
//                                    if reference.node.baseName.text == next.name {
//                                        return
//                                    }
//                                }
//                            }
//                        }
//                    }

                    // MARK: Missing Enviroment ObservableObject

                    Diagnostics.emit(.warning, message: "Insert object of type '\(property.baseType!)' in environment with 'environmentObject' up in the hierarchy", node: property.decl, file: view.file)

                }

            }

        }

    }

}
