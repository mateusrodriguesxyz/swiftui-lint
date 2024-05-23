import SwiftSyntax

final class SimplifyDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        let modifiers = ["background", "contentShape", "clipShape", "buttonStyle", "pickerStyle", "listStyle", "labelStyle"]
        
        for match in AnyCallCollector(modifiers, from: view.node).matches {
            
            let shapes = [
                "Rectangle": "rect",
                "RoundedRectangle": "rect",
                "Circle": "circle",
                "Capsule": "capsule",
                "Ellipse": "ellipse",
                "ContainerRelativeShape": "containerRelative"
            ]
            
            if ["contentShape", "clipShape", "background"].contains(match.name) {
                check(shapes)
            }
            
            if match.name == "buttonStyle" {
                let buttonStyles = [
                    "DefaultButtonStyle": "automatic",
                    "AccessoryBarButtonStyle": "accessoryBar",
                    "AccessoryBarActionButtonStyle": "accessoryBarAction",
                    "BorderedButtonStyle": "bordered",
                    "BorderedProminentButtonStyle": "borderedProminent",
                    "BordelessButtonStyle": "borderless",
                    "CardButtonStyle": "card",
                    "LinkButtonStyle": "link",
                    "PlainButtonStyle": "plain",
                ]
                check(buttonStyles)
            }
            
            if match.name == "pickerStyle" {
                let pickerStyles = [
                    "DefaultPickerStyle": "automatic",
                    "InlinePickerStyle": "inline",
                    "MenuPickerStyle": "menu",
                    "NavigationLinkPickerStyle": "navigationLink",
                    "PalettePickerStyle": "palette",
                    "RadioGroupPickerStyle": "radioGroup",
                    "SegmentedPickerStyle": "segmented",
                    "WheelPickerStyle": "wheel",
                ]
                check(pickerStyles)
            }
            
            if match.name == "listStyle" {
                let listStyles = [
                    "DefaultListStyle": "automatic",
                    "BorderedListStyle": "bordered",
                    "CarouselListStyle": "carousel",
                    "EllipticalListStyle": "elliptical",
                    "GroupedListStyle": "grouped",
                    "InsetListStyle": "inset",
                    "InsetGroupedListStyle": "insetGrouped",
                    "PlainListStyle": "plain",
                    "SidebarListStyle": "sidebar",
                ]
                check(listStyles)
            }
            
            if match.name == "labelStyle" {
                let labelStyles = [
                    "DefaultLabelStyle": "automatic",
                    "IconOnlyLabelStyle": "iconOnly",
                    "TitleAndIconLabelStyle": "titleAndIcon",
                    "TitleOnlyLabelStyle": "titleOnly",
                ]
                check(labelStyles)
            }
            
            func check(_ options: [String: String]) {
                guard let option = (match.arguments["in"] ?? match.arguments.first)?.expression.as(FunctionCallExprSyntax.self) else {
                    return
                }
                if let simplified = options[option.calledExpression.trimmedDescription] {
                    let arguments = option.arguments.map { ($0.label?.trimmedDescription ?? "") + ":" }
                    if arguments.isEmpty {
                        warning("Consider using '.\(simplified)' for simplicity", node: option, file: view.file)
                    } else {
                        warning("Consider using '.\(simplified)(\(arguments.joined()))' for simplicity", node: option, file: view.file)
                    }
                }
            }
            
//            func check2(_ argument: KeyPath<LabeledExprListSyntax, LabeledExprListSyntax.Element?>, _ options: [String: String]) {
//                let argument = match.arguments[keyPath: argument]
//                guard let option = argument?.expression.as(FunctionCallExprSyntax.self) else {
//                    return
//                }
//                            
//                if let simplified = options[option.calledExpression.trimmedDescription] {
//                    let arguments = option.arguments.map { ($0.label?.trimmedDescription ?? "") + ":" }
//                    if arguments.isEmpty {
//                        warning("Consider using '.\(simplified)' for simplicity", node: option, file: view.file)
//                    } else {
//                        warning("Consider using '.\(simplified)(\(arguments.joined()))' for simplicity", node: option, file: view.file)
//                    }
//                }
//            }
//            
        }
        
    }
    
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: FunctionCallExprSyntax) {
        appendInterpolation(value.calledExpression.trimmedDescription)
    }
}
