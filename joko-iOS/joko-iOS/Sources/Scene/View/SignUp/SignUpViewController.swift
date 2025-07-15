import UIKit
import SnapKit
import Then
import Moya
import RxSwift
import RxCocoa

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
    private let signUpButton = JokoButton(
        buttonText: "회원가입하기",
        isHidden: false
    )
 
    public override func attribute() {
        super.attribute()
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func addView() {
        [
            titleLabel,
            nickNameTextField,
            idTextField,
            passwordTextField,
            signUpButton
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
        
         signUpButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    public override func bind() {
        let input = SignUpViewModel.Input(
            username: nickNameTextField.textField.rx.text.orEmpty.asDriver(),
            accountId: idTextField.textField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.textField.rx.text.orEmpty.asDriver(),
            signUpTap: signUpButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input: input)

        output.isSignUpEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
                self?.signUpButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        output.signUpSuccess
            .drive(onNext: { [weak self] in
                self?.signUpSuccess()
            })
            .disposed(by: disposeBag)

        output.signUpError
            .drive(onNext: { [weak self] errorMessage in
                self?.showAlert(title: "회원가입 실패", message: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    private func showLoading() {
        signUpButton.isEnabled = false
        signUpButton.setTitle("회원가입 중...", for: .normal)
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        signUpButton.setTitle("회원가입하기", for: .normal)
        view.isUserInteractionEnabled = true
    }
    
    private func signUpSuccess() {
        showAlert(title: "회원가입 성공", message: "회원가입이 완료되었습니다!") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
