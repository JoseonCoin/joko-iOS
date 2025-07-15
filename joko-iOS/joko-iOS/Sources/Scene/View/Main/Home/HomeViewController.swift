import UIKit
import SnapKit
import Then

final class HomeViewController: BaseViewController<HomeViewModel> {
    private let navigationBar = JokoMainNavigationBar()
    private let topSkyView = UIView().then {
        $0.backgroundColor = .skyblue
    }
    private let cloudImageView = UIImageView().then {
        $0.image = UIImage(named: "cloud")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white1
    }
    private let cloudImageView2 = UIImageView().then {
        $0.image = UIImage(named: "cloud")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white1
    }
    private let bottomBackView = UIView().then {
        $0.backgroundColor = .yellow1
    }
    public override func addView() {
        [
            topSkyView,
            cloudImageView,
            cloudImageView2,
            bottomBackView,
            navigationBar
        ].forEach { view.addSubview($0) }
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        navigationBar.backgroundColor = .clear
        hideKeyboardWhenTappedAround()
    }
    
    public override func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        topSkyView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(329)
        }
        bottomBackView.snp.makeConstraints {
            $0.top.equalTo(topSkyView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        cloudImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(119.04)
            $0.leading.equalTo(54.79)
            $0.width.equalTo(120)
            $0.height.equalTo(58.25)
        }
        cloudImageView2.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(74.29)
            $0.trailing.equalToSuperview().inset(51.75)
        }
    }
}
