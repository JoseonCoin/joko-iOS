import UIKit
import SnapKit
import Then

final class ChangeEraViewController: BaseViewController<ChangeEraViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
        $0.text = "시대 변경"
        $0.textColor = .white1
    }
    private let explainLabel1 = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.numberOfLines = 0
        
        let fullText = "조코를 사용하면 시대를 변경할 수 있어요.\n선택한 시대에서 중요한 사건이 발생한 연도로 랜덤 이동하게 돼요."
        let highlightText = "중요한 사건이 발생한 연도로 랜덤 이동"
        
        $0.setHighlightedText(fullText,
                             highlightText: highlightText,
                             normalColor: .gray300,
                             highlightColor: .white1)
    }
    public override func attribute() {
        super.attribute()
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func addView() {
        [
            titleLabel,
            explainLabel1
        ].forEach { view.addSubview($0) }
    }
    
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(36)
            $0.leading.equalTo(20)
        }
        explainLabel1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(20)
        }
    }
}

