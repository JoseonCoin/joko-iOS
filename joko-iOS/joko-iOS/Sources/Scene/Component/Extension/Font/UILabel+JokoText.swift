import UIKit

extension UILabel {
    func setJokoText(_ text: String, style: JokoFontStyle, color: UIColor) {
        self.attributedText = UIFont.JokoFont(style).attributedString(from: text, style: style)
        self.textColor = color
    }
}
