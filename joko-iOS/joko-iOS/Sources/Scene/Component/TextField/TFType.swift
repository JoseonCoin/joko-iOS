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
    
    var iconClick = true
    
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
        $0.setImage(UIImage(systemName: "eyeOn"), for: .normal)
        $0.setImage(UIImage(systemName: "eyeOff"), for: .selected)
        $0.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    init(type: TFType) {
        super.init(frame: .zero)
        
        titleLabel.text = type.text
        textField.attributedPlaceholder = NSAttributedString(string: type.text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray200])
        
        switch type {
        case .id:
            textField.addLeftView()
            textField.addRightView()
        case .name:
            textField.addLeftView()
            textField.addRightView()
        case .pw:
            textField.isSecureTextEntry = true
            textField.addLeftView()
            // 패스워드 필드는 showPasswordButton을 rightView로 사용
            let containerView = UIView()
            containerView.addSubview(showPasswordButton)
            showPasswordButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-16)
                $0.width.height.equalTo(24)
            }
            textField.rightView = containerView
            textField.rightViewMode = .always
        case .custom:
            let texts = type.text.components(separatedBy: ",")
            titleLabel.text = texts[0]
            textField.attributedPlaceholder = NSAttributedString(string: texts[1], attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray200])
            textField.addLeftView()
            textField.addRightView()
        }
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            $0.left.right.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(44.0)
        }
    }
    
    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()
        iconClick.toggle()
    }
    
    public func currentText() -> String {
        return textField.text ?? ""
    }
}
