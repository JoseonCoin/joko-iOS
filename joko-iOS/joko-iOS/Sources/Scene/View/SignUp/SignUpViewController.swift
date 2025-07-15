import UIKit
import SnapKit
import Then
import Moya

public class SignUpViewController: BaseViewController<SignUpViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
        $0.text = "회원가입하고\n조코 사용하기"
        $0.textColor = .white
        $0.numberOfLines = 0
    }

    private let nickNameTextField = JokoTextField(type: .name)
    private let idTextField = JokoTextField(type: .id)
    private let passwordTextField = JokoTextField(type: .pw)
    
    public override func attribute() {
        super.attribute()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .background
    }
    
    public override func addView() {
        [
            titleLabel,
            idTextField,
            nickNameTextField,
            passwordTextField
        ].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.leading.equalToSuperview().inset(20)
        }
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        idTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

