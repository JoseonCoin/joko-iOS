import UIKit
import SnapKit
import Then

enum TFType {
    case id
    case name
    case pw
    case custom(title: String, placeholder: String)

    var text: String {
        switch self {
        case .id:
            return "아이디"
        case .name:
            return "닉네임"
        case .pw:
            return "비밀번호"
        case .custom(let title, let placeholder):
            return title + "," + placeholder
        }
    }
}

class JokoTextField: UIView {

    let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.label)
        $0.textColor = .white1
    }

    let textField = UITextField().then {
        $0.font = UIFont.JokoFont(.placeholder)
        $0.isSecureTextEntry = false
        $0.keyboardType = .default
        $0.backgroundColor = .middleBlack
        $0.layer.cornerRadius = 8.0
        $0.layer.masksToBounds = true
    }

    let showPasswordButton = UIButton().then {
        $0.tintColor = .gray200
        $0.setImage(UIImage(named: "eyeOff"), for: .normal)
        $0.setImage(UIImage(named: "eyeOn"), for: .selected)
    }

    init(type: TFType) {
        super.init(frame: .zero)

        titleLabel.text = type.text
        textField.attributedPlaceholder = NSAttributedString(
            string: type.text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray200]
        )

        switch type {
        case .id, .name:
            textField.setPadding(left: 16, right: 16)

        case .pw:
            textField.isSecureTextEntry = true
            setupPasswordButton()

        case .custom:
            let texts = type.text.components(separatedBy: ",")
            titleLabel.text = texts[0]
            textField.attributedPlaceholder = NSAttributedString(
                string: texts[1],
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray200]
            )
            textField.setPadding(left: 16, right: 16)
        }

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupPasswordButton() {
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always

        let containerWidth: CGFloat = 48
        let containerHeight: CGFloat = 44
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))

        showPasswordButton.frame = CGRect(x: containerWidth - 36, y: (containerHeight - 24) / 2, width: 24, height: 24)
        containerView.addSubview(showPasswordButton)

        textField.rightView = containerView
        textField.rightViewMode = .always
    }


    func layout() {
        [titleLabel, textField].forEach { self.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(19.0)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44.0) // 👈 명시적으로 height 지정
            $0.bottom.equalToSuperview() // 이건 나중에 작동함
        }

    }

    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()
        showPasswordButton.isSelected = !textField.isSecureTextEntry

        // iOS placeholder 버그 대응 (토글 시 placeholder 안 보이는 문제 해결)
        let currentText = textField.text
        textField.text = ""
        textField.text = currentText
    }

    public func currentText() -> String {
        return textField.text ?? ""
    }
}

// MARK: - Padding Extension
extension UITextField {
    func setPadding(left: CGFloat = 0, right: CGFloat = 0) {
        if left > 0 {
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: 0))
            self.leftView = leftView
            self.leftViewMode = .always
        }
        if right > 0 {
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: 0))
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
}
