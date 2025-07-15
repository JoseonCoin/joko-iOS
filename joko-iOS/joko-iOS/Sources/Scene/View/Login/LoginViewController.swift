import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Moya

public class LoginViewController: BaseViewController<LoginViewModel> {
    let provider = MoyaProvider<LoginAPI>(plugins: [MoyaLoggingPlugin()])
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

    // MARK: - Binding
    public override func bind() {
        let input = LoginViewModel.Input(
            accountId: idTextField.textField.rx.text.orEmpty.asDriver(),
            password: pwTextField.textField.rx.text.orEmpty.asDriver(),
            loginTap: loginButton.rx.tap.asDriver(),
            signUpTap: signUpButton.rx.tap.asDriver()
        )

        let output = viewModel.transform(input: input)

        // 로그인 버튼 활성화
        output.isLoginEnabled
            .drive(onNext: { [weak self] (isEnabled: Bool) in
                self?.loginButton.isEnabled = isEnabled
                self?.loginButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        // 로딩 처리
        output.isLoading
            .drive(onNext: { [weak self] (isLoading: Bool) in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        // 로그인 성공
        output.loginSuccess
            .drive(onNext: { [weak self] in
                self?.loginSuccess()
            })
            .disposed(by: disposeBag)

        // 로그인 실패
        output.loginError
            .drive(onNext: { [weak self] errorMessage in
                self?.showAlert(title: "로그인 실패", message: errorMessage)
            })
            .disposed(by: disposeBag)

        // 회원가입
        output.signUpTap
            .drive(onNext: { [weak self] in
                self?.navigateToSignUp()
            })
            .disposed(by: disposeBag)
    }

    private func showLoading() {
        loginButton.isEnabled = false
        loginButton.setTitle("로그인 중...", for: .normal)
        view.isUserInteractionEnabled = false
    }

    private func hideLoading() {
        loginButton.setTitle("로그인하기", for: .normal)
        view.isUserInteractionEnabled = true
    }

    private func loginSuccess() {
        showAlert(title: "로그인 성공", message: "환영합니다!") { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private func navigateToSignUp() {
        print("회원가입 버튼 클릭")

        let signUpVC = SignUpViewController(viewModel: SignUpViewModel())

        if let navController = navigationController {
            // NavigationController가 있으면 push
            navController.pushViewController(signUpVC, animated: true)
        } else {
            // NavigationController가 없으면 새로 생성해서 present
            let navController = UINavigationController(rootViewController: signUpVC)
            present(navController, animated: true)
        }
    }
}
