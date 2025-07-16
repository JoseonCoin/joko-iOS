import UIKit
import SnapKit
import Then

final class QuizViewController: BaseViewController<QuizViewModel> {
    private let coinPriceLabel = UILabel().then {
        $0.font = .JokoFont(.title3)
        $0.text = "조코 불러오는중..."
        $0.textColor = .main
    }
    private let quizImageView = UIImageView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 24
    }
    private let questionLabel = UILabel().then {
        $0.font = .JokoFont(.title2)
        $0.text = "문제 불러오는 중..."
        $0.textColor = .white1
    }
    
    public override func addView() {
        [
            coinPriceLabel,
            quizImageView,
            questionLabel
        ].forEach { view.addSubview($0) }
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func setLayout() {
        coinPriceLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.centerX.equalToSuperview()
        }
        quizImageView.snp.makeConstraints {
            $0.top.equalTo(coinPriceLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(115)
            $0.width.height.equalTo(160)
        }
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(quizImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
    }
}
