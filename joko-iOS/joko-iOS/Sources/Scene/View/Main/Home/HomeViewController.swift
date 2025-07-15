import UIKit
import SnapKit
import Then

final class HomeViewController: BaseViewController<HomeViewModel> {
    private let topImageView = UIView().then {
        $0.backgroundColor = .skyblue
    }
    
    public override func addView() {
        [
            topImageView
        ].forEach { view.addSubview($0) }
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func setLayout() {
        topImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(329)
        }

    }
}
