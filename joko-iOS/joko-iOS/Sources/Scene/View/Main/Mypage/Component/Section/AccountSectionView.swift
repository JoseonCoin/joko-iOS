import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class AccountSectionView: BaseView {
    enum AccountSectionType: Int {
        case interestField = 0
        case changePassword = 1
        case logout = 2
        case withDraw = 3
    }
    private let accountSectionView = SectionView(
        menuText: "계정",
        items: [
            ("관심분야 선택"),
            ("비밀번호 변경",),
            ("로그아웃"),
            ("회원 탈퇴")
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
