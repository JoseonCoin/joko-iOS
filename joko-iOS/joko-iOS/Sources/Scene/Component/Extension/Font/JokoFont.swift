import UIKit
import Foundation

public extension UIFont {
    static func JokoFont(_ font: JokoFontStyle) -> UIFont {
        return font.uiFont()
    }
}

extension JokoFontStyle {
    func uiFont() -> UIFont {
        switch self {
        // Title - SemiBold
        case .title1, .title2, .title3:
            return UIFont(name: "WantedSans-SemiBold", size: self.size()) ?? UIFont.systemFont(ofSize: self.size(), weight: .semibold)
            
        // SemiBold - SemiBold
        case .semiBold1, .semiBold2:
            return UIFont(name: "WantedSans-SemiBold", size: self.size()) ?? UIFont.systemFont(ofSize: self.size(), weight: .semibold)
            
        // Body - Regular
        case .body1, .body2, .body3, .body4:
            return UIFont(name: "WantedSans-Regular", size: self.size()) ?? UIFont.systemFont(ofSize: self.size(), weight: .regular)
            
        // etc - Regular
        case .label, .placeholder:
            return UIFont(name: "WantedSans-Regular", size: self.size()) ?? UIFont.systemFont(ofSize: self.size(), weight: .regular)
            
        // Button - SemiBold
        case .button:
            return UIFont(name: "WantedSans-SemiBold", size: self.size()) ?? UIFont.systemFont(ofSize: self.size(), weight: .semibold)
        }
    }
    
    func size() -> CGFloat {
        switch self {
        // Title
        case .title1:
            return 32
        case .title2:
            return 24
        case .title3:
            return 20
            
        // SemiBold
        case .semiBold1:
            return 20
        case .semiBold2:
            return 16
            
        // Body
        case .body1:
            return 18
        case .body2:
            return 14
        case .body3:
            return 12
        case .body4:
            return 10
            
        // etc
        case .label:
            return 14
        case .placeholder:
            return 12
        case .button:
            return 16
        }
    }
}
