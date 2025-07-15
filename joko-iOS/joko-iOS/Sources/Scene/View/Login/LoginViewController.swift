import UIKit
import SnapKit
import Then

public class LoginViewController: BaseViewController<LoginViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
        $0.text = "로그인하고\n조코 사용하기"
        $0.textColor = .white
        $0.numberOfLines = 0
    }

    private let idTextField = JokoTextField(type: .id)
    private let pwTextField = JokoTextField(type: .pw)

    private let nonAccountLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "아직 계정이 없으신가요?"
        $0.textColor = .gray400
    }

    private let signUpButton = JokoUnderlineButton(
        buttonText: "회원가입"
    )

    private let loginButton = JokoButton(
        buttonText: "로그인하기",
        isHidden: false
    )

    public override func addView() {
        [
            titleLabel,
            idTextField,
            pwTextField,
            nonAccountLabel,
            signUpButton,
            loginButton
        ].forEach { view.addSubview($0) }
    }

    public override func attribute() {
        view.backgroundColor = .background
    }

    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.leading.equalToSuperview().inset(20)
        }
        idTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        nonAccountLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(572)
            $0.leading.trailing.equalToSuperview().inset(112)
        }
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(572)
            $0.leading.equalTo(nonAccountLabel.snp.trailing).inset(8)
            $0.width.equalTo(42)
        }
        loginButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(604)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

}
