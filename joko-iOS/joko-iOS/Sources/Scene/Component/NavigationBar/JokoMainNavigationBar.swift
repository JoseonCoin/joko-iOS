import UIKit
import SnapKit
import Then

public class JokoMainNavigationBar: UIView {
    private let sinceBackView = UIView().then {
        
    }
    private let sinceButton = UIButton().then {
        $0.setTitle("조선 전기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .chosunFont(size: 20)
    }


    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 390, height: 44)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sinceButton)
        sinceButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9.5)
            $0.bottom.equalToSuperview().inset(9.5)
            $0.leading.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
