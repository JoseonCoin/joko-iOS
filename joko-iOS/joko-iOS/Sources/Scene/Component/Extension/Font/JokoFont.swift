import UIKit
import Foundation

public extension UIFont {
    static func JokoFont(_ font: JokoFontStyle) -> UIFont {
        return font.uiFont()
    }
    
    // Convenience method for custom sizes
    static func JokoFont(_ font: JokoFontStyle, size: CGFloat) -> UIFont {
        return font.uiFont(customSize: size)
    }
}

public enum JokoFontStyle {
    case title1
    case title2
    case title3
    case semiBold1
    case semiBold2
    case body1
    case body2
    case body3
    case body4
    case label
    case placeholder
    case button
    
    // Additional semantic cases
    case caption
    case footnote
    case callout
    case subheadline
    case headline
}

extension JokoFontStyle {
    func uiFont(customSize: CGFloat? = nil) -> UIFont {
        let fontSize = customSize ?? self.size()
        let fontName = self.fontName()
        let fallbackWeight = self.fallbackWeight()
        
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: fallbackWeight)
    }
    
    private func fontName() -> String {
        switch self {
        // Title - SemiBold
        case .title1, .title2, .title3:
            return "WantedSans-SemiBold"
            
        // SemiBold - SemiBold
        case .semiBold1, .semiBold2:
            return "WantedSans-SemiBold"
            
        // Body - Regular
        case .body1, .body2, .body3, .body4:
            return "WantedSans-Regular"
            
        // etc - Regular
        case .label, .placeholder, .caption, .footnote, .callout:
            return "WantedSans-Regular"
            
        // Button - SemiBold
        case .button:
            return "WantedSans-SemiBold"
            
        // Additional cases
        case .subheadline:
            return "WantedSans-Medium"
        case .headline:
            return "WantedSans-Bold"
        }
    }
    
    private func fallbackWeight() -> UIFont.Weight {
        switch self {
        case .title1, .title2, .title3, .semiBold1, .semiBold2, .button:
            return .semibold
        case .headline:
            return .bold
        case .subheadline:
            return .medium
        default:
            return .regular
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
            
        // Additional cases
        case .caption:
            return 11
        case .footnote:
            return 13
        case .callout:
            return 15
        case .subheadline:
            return 17
        case .headline:
            return 22
        }
    }
    
    // Line height for better typography
    func lineHeight() -> CGFloat {
        switch self {
        case .title1:
            return 40
        case .title2:
            return 32
        case .title3:
            return 28
        case .semiBold1:
            return 28
        case .semiBold2:
            return 24
        case .body1:
            return 26
        case .body2:
            return 20
        case .body3:
            return 18
        case .body4:
            return 16
        case .label:
            return 20
        case .placeholder:
            return 18
        case .button:
            return 24
        case .caption:
            return 16
        case .footnote:
            return 18
        case .callout:
            return 22
        case .subheadline:
            return 24
        case .headline:
            return 30
        }
    }
}

// MARK: - Additional Typography Helpers
public extension UIFont {
    // Create attributed string with proper line height
    func attributedString(from text: String, style: JokoFontStyle) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineHeight() - style.size()
        paragraphStyle.minimumLineHeight = style.lineHeight()
        paragraphStyle.maximumLineHeight = style.lineHeight()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

// MARK: - Font Registration Helper
public class JokoFontLoader {
    static func registerFonts() {
        let fontNames = [
            "WantedSans-Black",
            "WantedSans-Bold",
            "WantedSans-ExtraBlack",
            "WantedSans-ExtraBold",
            "WantedSans-Medium",
            "WantedSans-Regular",
            "WantedSans-SemiBold"
        ]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") ?? Bundle.main.url(forResource: fontName, withExtension: "otf") else {
                print("Could not find font file: \(fontName)")
                continue
            }
            
            guard let fontData = NSData(contentsOf: fontURL) else {
                print("Could not load font data: \(fontName)")
                continue
            }
            
            guard let provider = CGDataProvider(data: fontData) else {
                print("Could not create font provider: \(fontName)")
                continue
            }
            
            guard let font = CGFont(provider) else {
                print("Could not create font: \(fontName)")
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Could not register font: \(fontName), error: \(error.debugDescription)")
            }
        }
    }
}
