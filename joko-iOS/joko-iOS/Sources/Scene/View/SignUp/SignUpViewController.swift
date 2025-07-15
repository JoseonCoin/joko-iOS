import UIKit
import SnapKit
import Then

public class SignUpViewController: BaseViewController<SignUpViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
        $0.text = "회원가입하고\n조코 사용하기"
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    public override func attribute() {
        super.attribute()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    public override func addView() {
        [
            titleLabel
        ].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}

