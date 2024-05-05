import SwiftSyntax

struct AlignmentWrapper {
    
    let horizontal: String?
    let vertical: String?
    
    init(_ expression: ExprSyntax, isAlignmentGuide: Bool = false) {
        
        guard let expression = expression.as(MemberAccessExprSyntax.self) else {
            self.horizontal = nil
            self.vertical = nil
            return
        }
        
        let declName = expression.declName.trimmedDescription
        
        let base = expression.base?.trimmedDescription
        
        var horizontal: String? = nil
        var vertical: String? = nil
        
        switch base {
            case "HorizontalAlignment":
                horizontal = "HorizontalAlignment.\(declName)"
            case "VerticalAlignment":
                vertical = "VerticalAlignment.\(declName)"
            default:
                switch declName {
                    case "leading", "trailing":
                        horizontal = "HorizontalAlignment.\(declName)"
                        if !isAlignmentGuide {
                            vertical = "VerticalAlignment.center"
                        }
                    case "top", "bottom":
                        if !isAlignmentGuide {
                            horizontal = "HorizontalAlignment.center"
                        }
                        vertical = "VerticalAlignment.\(declName)"
                    case "topLeading":
                        horizontal = "HorizontalAlignment.leading"
                        vertical = "VerticalAlignment.top"
                    case "topTrailing":
                        horizontal = "HorizontalAlignment.trailing"
                        vertical = "VerticalAlignment.top"
                    case "bottomLeading":
                        horizontal = "HorizontalAlignment.leading"
                        vertical = "VerticalAlignment.bottom"
                    case "bottomTrailing":
                        horizontal = "HorizontalAlignment.trailing"
                        vertical = "VerticalAlignment.bottom"
                    default:
                        break
                }
        }
        
        self.horizontal = horizontal
        self.vertical = vertical
        
    }
    
    
}
