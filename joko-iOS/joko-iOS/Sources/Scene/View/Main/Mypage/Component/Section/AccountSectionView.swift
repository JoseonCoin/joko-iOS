import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class AccountSectionView: BaseView {
    enum AccountSectionType: Int {
        case logout = 2
    }
    private let accountSectionView = SectionView(
        menuText: "계정",
        items: [
            ("로그아웃", .selectHome)
        ]
    )

    override func addView() {
        self.addSubview(accountSectionView)
    }

    override func setLayout() {
        accountSectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func getSelectedItem(type: AccountSectionType) -> Observable<IndexPath> {
        self.accountSectionView.getSelectedItem(index: type.rawValue)
    }
}
