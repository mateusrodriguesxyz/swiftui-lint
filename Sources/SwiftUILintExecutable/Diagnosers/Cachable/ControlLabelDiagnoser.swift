import SwiftSyntax
import Foundation

final class ControlLabelDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: view.node).calls {
            for innerControl in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: control.additionalTrailingClosures).calls {
                warning("'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
            }
        }
        
        for control in AnyCallCollector(["Stepper", "Toggle", "Picker", "DatePicker", "MultiDatePicker", "ColorPicker"], from: view.node).calls {
            if let label = control.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments, label.trimmedDescription.isEmpty {
                warning("Consider providing a non-empty label for accessibility purpose and using 'labelsHidden' modifier to omit it in the user interface", node: label, file: view.file)
            }
        }
        
        for _ in AnyCallCollector(["ToolbarItem", "ToolbarItemGroup"], from: view.node).matches {
            for control in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: view.node).calls {
                let modifiers = AllAppliedModifiersCollector(control)
                if !modifiers.contains("buttonStyle") {
                    let matches = modifiers.matches("font", "labelStyle")
                    if !matches.isEmpty {
                        let list = matches.map({ "'\($0.name)'" }).formatted(.list(type: .and).locale(Locale(identifier: "en_UK")))
                        warning("Apply 'buttonStyle(.borderless)' modifier so \(list) can take effect", node: control, file: view.file)
                    }
                }
            }
        }
        
        for list in AnyCallCollector(["List"], from: view.node).matches {
            
            guard let content = list.closure else { continue }
            
            let children = ChildrenCollector(content).children.compactMap({ ViewChildWrapper($0) })
            
            for child in children {
                if child.name == "Button" || child.name == "ForEach" {
                    continue
                }
                for match in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: child.node).matches {
                    if AllAppliedModifiersCollector(match.node).contains("buttonStyle") {
                        continue
                    }
                    warning("Apply 'buttonStyle' modifier with an explicit style to override default list row tap behavior", node: match.node, position: .start, offset: 0, file: view.file)
                }
            }
            
            for forEach in AnyCallCollector(["ForEach"], from: content).matches {
                guard let content = forEach.closure else { continue }
                let children = ChildrenCollector(content).children.compactMap({ ViewChildWrapper($0) })
                guard let child = children.first else { continue }
                if child.name == "Button" {
                    continue
                }
                for match in AnyCallCollector(["Button", "NavigationLink", "Link", "Menu"], from: content).matches {
                    if AllAppliedModifiersCollector(match.node).contains("buttonStyle") {
                        continue
                    }
                    warning("Apply 'buttonStyle' modifier with an explicit style to override default list row tap behavior", node: match.node, position: .start, offset: 0, file: view.file)
                }
            }
        }
        
    }
    
}
