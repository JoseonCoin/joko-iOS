import UIKit
import SnapKit
import Then

final class HomeViewController: BaseViewController<HomeViewModel> {
    private let navigationBar = JokoMainNavigationBar()
    private let backGround = UIImageView().then {
        $0.image = UIImage(named: "satto")?.withRenderingMode(.alwaysOriginal)
    }
    private let itemLabel = UILabel().then {
        $0.font = UIFont.chosunFont(size: 16)
        $0.text = "천민이 획득한 아이템"
    }

    public override func addView() {
        [
            backGround,
            itemLabel,
            navigationBar
        ].forEach { view.addSubview($0) }
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        navigationBar.backgroundColor = .clear
        hideKeyboardWhenTappedAround()
        navigationBar.parentViewController = self
    }
    
    public override func setLayout() {
        backGround.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        itemLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(504)
            $0.leading.equalToSuperview().inset(25)
        }
      
    }
}
