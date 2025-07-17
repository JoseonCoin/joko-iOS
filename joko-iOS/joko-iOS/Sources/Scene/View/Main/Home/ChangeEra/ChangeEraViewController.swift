import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class ChangeEraViewController: BaseViewController<ChangeEraViewModel> {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title2)
        $0.text = "시대 변경"
        $0.textColor = .white1
    }
    
    private let coinLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body2)
        $0.text = "0"  // 초기값을 0으로 설정
        $0.textColor = .white1
    }
    
    
    private let coinImageView = UIImageView().then {
        $0.image = UIImage(named: "coin_icon")?.withRenderingMode(.alwaysOriginal)
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
    
    // 조선 전기 카드
    private let jeongiCardView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    private let jeongiTitleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title3)
        $0.text = "조선 전기"
        $0.textColor = .white1
    }
    
    
    private let jeongiPeriodLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body1)
        $0.text = "1392년 ~ 1592년"
        $0.textColor = .gray300
    }
    private let jeongiCostLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "500조코"
        $0.textColor = .white1
    }
    
    private let jeongiStatusLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "현재 설정됨"
        $0.textColor = .white1
        $0.isHidden = true
    }
    
    // 조선 중기 카드
    private let junggiCardView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    private let junggiTitleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title3)
        $0.text = "조선 중기"
        $0.textColor = .white1
    }
    
    private let junggiPeriodLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body1)
        $0.text = "1592년 ~ 1728년"
        $0.textColor = .gray300
    }
    
    private let junggiCostLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "500조코"
        $0.textColor = .white1
    }
    
    private let junggiStatusLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "현재 설정됨"
        $0.textColor = .white1
        $0.isHidden = true
    }
    
    // 조선 후기 카드
    private let hugiCardView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    private let hugiTitleLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.title3)
        $0.text = "조선 후기"
        $0.textColor = .white1
    }
    
    private let hugiPeriodLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body1)
        $0.text = "1728년 ~ 1910년"
        $0.textColor = .gray300
    }
    
    private let hugiCostLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "500조코"
        $0.textColor = .white1
    }
    
    private let hugiStatusLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.body3)
        $0.text = "현재 설정됨"
        $0.textColor = .white1
        $0.isHidden = true
    }
    
    private let appearTrigger = PublishRelay<Void>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appearTrigger.accept(())
    }
    
    public override func bind() {
        print("📌 ChangeEraViewController bind() 실행됨")
        
        let input = ChangeEraViewModel.Input(appearTrigger: appearTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.currentEra
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] era in
                print("🏛️ 현재 시대: \(era)")
                self?.updateCurrentEra(era)
            })
            .disposed(by: disposeBag)
        
        output.coinAmount
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] coin in
                print("💰 코인 수량: \(coin)")
                self?.coinLabel.text = "\(coin)"
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCurrentEra(_ era: String) {
        // 모든 카드 초기화
        resetAllCards()
        
        // 현재 시대에 따라 해당 카드만 강조
        switch era {
        case "JEON_GI":
            highlightCard(jeongiCardView)
            jeongiStatusLabel.isHidden = false
            jeongiCostLabel.isHidden = true  // 현재 설정된 시대는 비용 숨김
            junggiCostLabel.isHidden = false
            hugiCostLabel.isHidden = false
            print("🖼️ 전기 시대 선택됨")
        case "JUNG_GI":
            highlightCard(junggiCardView)
            junggiStatusLabel.isHidden = false
            junggiCostLabel.isHidden = true  // 현재 설정된 시대는 비용 숨김
            jeongiCostLabel.isHidden = false
            hugiCostLabel.isHidden = false
            print("🖼️ 중기 시대 선택됨")
        case "HU_GI":
            highlightCard(hugiCardView)
            hugiStatusLabel.isHidden = false
            hugiCostLabel.isHidden = true  // 현재 설정된 시대는 비용 숨김
            jeongiCostLabel.isHidden = false
            junggiCostLabel.isHidden = false
            print("🖼️ 후기 시대 선택됨")
        default:
            print("🖼️ 알 수 없는 시대: \(era)")
        }
    }
    
    private func resetAllCards() {
        jeongiCardView.layer.borderColor = UIColor.clear.cgColor
        junggiCardView.layer.borderColor = UIColor.clear.cgColor
        hugiCardView.layer.borderColor = UIColor.clear.cgColor
        
        jeongiStatusLabel.isHidden = true
        junggiStatusLabel.isHidden = true
        hugiStatusLabel.isHidden = true
        
        // 모든 비용 라벨 다시 표시
        jeongiCostLabel.isHidden = false
        junggiCostLabel.isHidden = false
        hugiCostLabel.isHidden = false
    }
    
    private func highlightCard(_ cardView: UIView) {
        cardView.layer.borderColor = UIColor.systemYellow.cgColor
    }
    
    public override func attribute() {
        super.attribute()
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func addView() {
        [
            titleLabel,
            coinImageView,
            coinLabel,
            explainLabel1,
            jeongiCardView,
            junggiCardView,
            hugiCardView
        ].forEach { view.addSubview($0) }
        
        // 전기 카드 내부 요소들
        [
            jeongiTitleLabel,
            jeongiPeriodLabel,
            jeongiCostLabel,
            jeongiStatusLabel
        ].forEach { jeongiCardView.addSubview($0) }
        
        // 중기 카드 내부 요소들
        [
            junggiTitleLabel,
            junggiPeriodLabel,
            junggiCostLabel,
            junggiStatusLabel
        ].forEach { junggiCardView.addSubview($0) }
        
        // 후기 카드 내부 요소들
        [
            hugiTitleLabel,
            hugiPeriodLabel,
            hugiCostLabel,
            hugiStatusLabel
        ].forEach { hugiCardView.addSubview($0) }
    }
    
    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(36)
            $0.leading.equalTo(20)
        }
        
        coinImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(coinLabel.snp.leading).offset(-8)
            $0.size.equalTo(24)
        }
        
        coinLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        explainLabel1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        jeongiCardView.snp.makeConstraints {
            $0.top.equalTo(explainLabel1.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }
        
        jeongiTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        jeongiPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(jeongiTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(jeongiTitleLabel)
        }
        
        jeongiCostLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        jeongiStatusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        junggiCardView.snp.makeConstraints {
            $0.top.equalTo(jeongiCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }
        
        junggiTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        junggiPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(junggiTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(junggiTitleLabel)
        }
        
        junggiCostLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        junggiStatusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        hugiCardView.snp.makeConstraints {
            $0.top.equalTo(junggiCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }
        
        hugiTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        hugiPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(hugiTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(hugiTitleLabel)
        }
        
        hugiCostLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        hugiStatusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
