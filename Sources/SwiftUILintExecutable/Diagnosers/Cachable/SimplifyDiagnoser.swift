import SwiftSyntax

final class SimplifyDiagnoser: CachableDiagnoser {
    
    var diagnostics: [Diagnostic] = []
    
    func diagnose(_ view: ViewDeclWrapper) {
        
        let modifiers = ["clipShape", "buttonStyle", "pickerStyle", "listStyle", "labelStyle"]
        
        for match in AnyCallCollector(modifiers, from: view.node).matches {
            
            if match.name == "clipShape" {
                let shapes = [
                    "Rectangle": "rect",
                    "RoundedRectangle": "rect",
                    "Circle": "circle",
                    "Capsule": "capsule",
                    "Ellipse": "ellipse",
                    "ContainerRelativeShape": "trcontainerRelative"
                ]
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
                guard let option = match.arguments.first?.expression.as(FunctionCallExprSyntax.self)?.calledExpression else {
                    return
                }
                if let simplified = options[option.trimmedDescription] {
                    warning("Use '.\(simplified)' to simplify your code", node: option, file: view.file)
                }
            }
            
        }
        
    }
    
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: FunctionCallExprSyntax) {
        appendInterpolation(value.calledExpression.trimmedDescription)
    }
}
