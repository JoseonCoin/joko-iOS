import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

public class OXCollectionViewCell: UICollectionViewCell {
    static let identifier = "OXCollectionViewCell"
    
    private let quizOImageView = UIImageView().then {
        $0.image = UIImage(named: "quizO")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let quizXImageView = UIImageView().then {
        $0.image = UIImage(named: "quizX")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let backView = UIView().then {
        $0.backgroundColor = .middleBlack
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(backView)
        backView.addSubview(quizOImageView)
        backView.addSubview(quizXImageView)
    }
    
    private func setupConstraints() {
        backView.snp.makeConstraints {
            $0.width.equalTo(144)
            $0.height.equalTo(160)
            $0.center.equalToSuperview()
        }
        
        quizOImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(68)
        }
        
        quizXImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(58.8)
        }
    }
    
    func configure(isOSelected: Bool) {
        quizOImageView.isHidden = !isOSelected
        quizXImageView.isHidden = isOSelected
    }
}
