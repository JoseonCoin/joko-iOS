import UIKit
import SnapKit
import Then

final class ShopViewController: BaseViewController<ShopViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = .JokoFont(.title2)
        $0.textColor = .white1
        $0.text = "상점"
    }
}
