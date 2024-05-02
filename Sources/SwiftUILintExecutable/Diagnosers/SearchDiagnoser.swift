import SwiftSyntax

final class SearchDiagnoser: Diagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func run(context: Context) {
        
        for view in context.views {
            
            for match in AnyCallCollector(name: "searchScopes", view.node).matches {
                
                let scope: PropertyDeclWrapper? = {
                    if let name = match.arguments.first?.expression.trimmedDescription {
                        view.property(named: name)
                    } else {
                        nil
                    }
                }()
                
                guard let scope else { continue }
                
                guard let scopeType = scope._type(context)?.description else { continue }
                
                guard let scopeBaseType = scope._type(context)?.baseType else { continue }
                
                guard let children = match.closure?.statements else { continue }
                
                var forEachs = [ForEachWrapper]()
                
                for child in children {
                    if let forEach = ForEachWrapper(node: child) {
                        forEachs.append(forEach)
                    } else {
                        if let tag = child.tag() {
                            if let type = tag.type(context)?.description, type != scopeType {
                                warning("tag value '\(tag.value)' type '\(type)' doesn't match '\(scope.name)' type '\(scopeType)'", node: tag.node, file: view.file)
                            }
                        } else {
                            warning("Apply 'tag' modifier with '\(scopeType)' value to match '\(scope.name)' type", node: child, file: view.file)
                        }
                    }
                }
                
                for forEach in forEachs {
                    
                    guard let data = forEach.data else { continue }
                    
                    switch data {
                        case .range:
                            diagnose("Int", isRange: true)
                        case .property(let name):
                            
                            guard let property = view.property(named: name) else { break }
                            
                            guard let dataElementType = property.baseType(context) else {  break }
                            
                            if let customType = context.type(named: dataElementType) {
                                if let id = customType.property(named: (forEach.id ?? "id"), context: context), id.type != scopeType {
                                    if forEach.id != nil {
                                        warning("'ForEach' data element '\(customType.name.text)' member '\(id.name)' type '\(id.type!)' doesn't match '\(scope.name)' type '\(scopeType)'", node: forEach.node, file: view.file)
                                    } else {
                                        warning("'ForEach' data element '\(customType.name.text)' id type '\(id.type!)' doesn't match '\(scope.name)' type '\(scopeType)'", node: forEach.node, file: view.file)
                                    }
                                }
                            } else {
                                diagnose(dataElementType)
                            }
                            
                        case .array(let dataElementType):
                            diagnose(dataElementType)
                    }
                    
                    func diagnose(_ dataElementType: String, isRange: Bool = false) {
                        guard isRange || forEach.id == "self" else {
                            return
                        }
                        if dataElementType != scopeType {
                            if let tag = forEach.content!.tag() {
                                if let type = tag.type(context), type.description != scopeType {
                                    warning("tag value '\(tag.value)' type '\(type.description)' doesn't match '\(scope.name)' type '\(scopeType)'", node: tag.node, file: view.file)
                                }
                            } else {
                                if dataElementType == scopeBaseType, let content = forEach.content {
                                    warning("Apply 'tag' modifier with explicit Optional<\(scopeBaseType)> value to match '\(scope.name)' type '\(scopeType)'", node: content.lastToken(viewMode: .sourceAccurate)!, file: view.file)
                                } else {
                                    warning("'ForEach' data element type '\(dataElementType)' doesn't match '\(scope.name)' type '\(scopeType)'", node: forEach.node, file: view.file)
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}
