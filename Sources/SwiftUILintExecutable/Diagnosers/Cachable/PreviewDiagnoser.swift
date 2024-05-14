import SwiftSyntax

final class PreviewDiagnoser: CachableDiagnoser {

    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {

        if let preview = view.node.memberBlock.members.first(where: { $0.decl.as(MacroExpansionDeclSyntax.self)?.macroName.text == "Preview" }) {
            warning("'Preview' should be declared at the top level outside '\(view.name)'", node: preview, file: view.file)
        }
        
        if let preview = view.file.source.statements.first(where: { $0.item.as(MacroExpansionExprSyntax.self)?.macroName.text == "Preview" }) {
            if let call = AnyCallCollector(name: view.name, preview).calls.first {
                                
                for property in view.properties.filter({ $0.attribute("@Environment") != nil }) {
                    
                    var hasEnvironmentObject = false
                    
                    guard let type = property.type else { continue }
                    
                    for modifier in AllAppliedModifiersCollector(call).matches {
                        if modifier.name == "environment" {
                            if let object = modifier.arguments.first?.expression.as(FunctionCallExprSyntax.self) {
                                if object.calledExpression.trimmedDescription == type {
                                    hasEnvironmentObject = true
                                }
                            }
                        }
                    }
                    
                    if !hasEnvironmentObject {
                        warning("Insert object of type '\(type)' using 'environment' modifier", node: call, file: view.file)
                    }
                }
                
                for property in view.properties.filter({ $0.attribute("@EnvironmentObject") != nil }) {
                    
                    var hasEnvironmentObject = false
                    
                    guard let type = property.type else { continue }
                    
                    for modifier in AllAppliedModifiersCollector(call).matches {
                        if modifier.name == "environmentObject" {
                            if let object = modifier.arguments.first?.expression.as(FunctionCallExprSyntax.self) {
                                if object.calledExpression.trimmedDescription == type {
                                    hasEnvironmentObject = true
                                }
                            }
                        }
                    }
                    
                    if !hasEnvironmentObject {
                        warning("Insert object of type '\(type)' using 'environment' environmentObject", node: call, file: view.file)
                    }
                }
            }
        }

    }

}