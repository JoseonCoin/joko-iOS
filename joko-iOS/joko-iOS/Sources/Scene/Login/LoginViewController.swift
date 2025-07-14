import UIKit
import SnapKit
import Then

public class LoginViewController: BaseViewController<LoginViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
    }
    
    public override func addView() {
        [
            titleLabel
        ].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(80)
        }
    }

}
