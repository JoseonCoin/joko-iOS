import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class AnswerOViewController: UIViewController {
    private let smallLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title3)
        $0.text = "정답입니다!"
        $0.textColor = .white1
    }
    private let getCoinLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title1)
        $0.text = "1조코 "
        $0.textColor = .white1
    }
}
