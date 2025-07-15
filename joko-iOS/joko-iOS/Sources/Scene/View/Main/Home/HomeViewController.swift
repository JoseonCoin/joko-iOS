import UIKit
import SnapKit
import Then

final class HomeViewController: BaseViewController<HomeViewModel> {
    private let navigationBar = JokoMainNavigationBar()
    private let nobiBackGround = UIImageView().then {
        $0.image = UIImage(named: "satto")?.withRenderingMode(.alwaysOriginal)
    }
    public override func addView() {
        [
            nobiBackGround,
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
        nobiBackGround.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}
