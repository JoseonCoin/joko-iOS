import Foundation
import UIKit

extension UILabel {
    func setHighlightedText(_ fullText: String, highlightText: String, normalColor: UIColor, highlightColor: UIColor) {
        let attributedString = NSMutableAttributedString(string: fullText)

        attributedString.addAttribute(.foregroundColor,
                                    value: normalColor,
                                    range: NSRange(location: 0, length: fullText.count))
        

        let range = (fullText as NSString).range(of: highlightText)
        
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor,
                                        value: highlightColor,
                                        range: range)
        }
        
        self.attributedText = attributedString
    }
}
