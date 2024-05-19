import SwiftSyntax

final class ControlLabelDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: view.node).calls {
            
            for innerControl in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: control.additionalTrailingClosures).calls {
                warning("'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
            
            if let label = control.additionalTrailingClosures.first {
                let children = ChildrenCollector(label).children
                if children.count == 1, let child = children.first, child.firstToken(viewMode: .sourceAccurate)?.text == "Image" {
                    if let image = AnyCallCollector("Image", from: child).calls.first {
                        if control.calledExpression.trimmedDescription == "Button" {
                            warning("Use 'Button(_:systemImage:action:)' or 'Label(_:systemImage:)' to provide an accessibility label", node: image, file: view.file)
                        } else {
                            warning("Use 'Label(_:systemImage:)' to provide an accessibility label", node: image, file: view.file)
                        }
                    }
                }
            }
            
        }
        
        for control in AnyCallCollector(["Stepper", "Toggle", "Picker", "DatePicker", "MultiDatePicker", "ColorPicker"], from: view.node).calls {
            
            if let label = control.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments, label.trimmedDescription.isEmpty {
                warning("Consider providing a non-empty label for accessibility purpose and using 'labelsHidden' modifier to omit it in the user interface", node: label, file: view.file)
                
            }
            
        }
        
        for item in AnyCallCollector(["ToolbarItem", "ToolbarItemGroup"], from: view.node).matches {
            for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: view.node).calls {
                let modifiers = AllAppliedModifiersCollector(control)
                if !modifiers.contains("buttonStyle") {
                    for modifier in modifiers.matches("font", "labelStyle") {
                        warning("⬅️", node: modifier.decl, file: view.file)
                    }
                }
            }
        }
        
        for list in AnyCallCollector(["List"], from: view.node).matches {
            guard let content = list.closure else { continue }
            for forEach in AnyCallCollector(["ForEach"], from: content).matches {
                guard let content = forEach.closure else { continue }
                let children = ChildrenCollector(content).children.compactMap({ ViewChildWrapper($0) })
                guard let child = children.first else { continue }
                if child.name == "Button" {
                    continue
                }
                for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: content).calls {
                    warning("Apply 'buttonStyle(.borderless) modifier to disable the default row tap behavior", node: child.node, position: .end, offset: -1, file: view.file)
                }
            }
        }
        
    }
    
}
