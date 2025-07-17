import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController<HomeViewModel> {
    private let navigationBar = JokoMainNavigationBar()
    private let backGround = UIImageView().then {
        $0.image = UIImage(named: "satto")?.withRenderingMode(.alwaysOriginal)
    }
    private let eraImageView = UIImageView().then {
        $0.image = UIImage(named: "underbutton1")?.withRenderingMode(.alwaysOriginal)
    }
    private let coinImageView = UIImageView().then {
         $0.image = UIImage(named: "PlainCoin")?.withRenderingMode(.alwaysOriginal)
    }
    private let coinLabel = UILabel().then {
        $0.font = UIFont.JokoFont(.semiBold2)
        $0.text = "코인 불러오는중..."
        $0.textColor = .background
    }
    private let itemLabel = UILabel().then {
        $0.font = UIFont.chosunFont(size: 16)
        $0.text = "천민이 획득한 아이템"
    }

    private let appearTrigger = PublishRelay<Void>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 viewWillAppear - 홈 화면 나타남")
        appearTrigger.accept(())
    }

    public override func bind() {
        print("📌 bind() 실행됨")

        let input = HomeViewModel.Input(appearTrigger: appearTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.userId
            .compactMap { $0 }
            .subscribe(onNext: { userId in
                print("✅ 유저 아이디: \(userId)")
                UserDefaults.standard.set(userId, forKey: "user_id")
            })
            .disposed(by: disposeBag)
        
        output.userInfo
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] userInfo in
                print("✅ 유저 정보: \(userInfo)")
                self?.updateUI(with: userInfo)
            })
            .disposed(by: disposeBag)
            
        // 로딩 상태 처리
        output.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                self?.handleLoadingState(isLoading)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        if isLoading {
            coinLabel.text = "코인 불러오는중..."
            print("🔄 로딩 중...")
        }
    }
    
    private func updateUI(with userInfo: UserInfoResponse) {
        print("🪙 코인: \(userInfo.coin)")
        print("🏛️ 시대: \(userInfo.era)")
        print("👨‍💼 직업: \(userInfo.job)")
        print("🎖️ 계급: \(userInfo.rank)")
        
        itemLabel.text = "\(userInfo.rank)이 획득한 아이템"
        coinLabel.text = "\(userInfo.coin)"
        updateBackgroundImage(for: userInfo.job)
        updateEraImage(for: userInfo.era)
    }
    
    private func updateBackgroundImage(for job: String) {
        let imageName: String
        
        switch job {
        case "NOBI":
            imageName = "nobi"
        case "NONGMIN":
            imageName = "nongmin"
        case "SANGIN":
            imageName = "sangmin"
        case "SATTO":
            imageName = "satto"
        case "HYANGNI":
            imageName = "hyangri"
        case "JIJU":
            imageName = "yangban"
        case "KING":
            imageName = "king"
        default:
            imageName = "nobi"
        }
        
        backGround.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        print("🖼️ 배경 이미지 변경: \(imageName)")
    }
    
    private func updateEraImage(for era: String) {
        let imageName: String
        
        switch era {
        case "JEON_GI":
            imageName = "underbutton1"
        case "JUNG_GI":
            imageName = "underbutton2"
        case "HU_GI":
            imageName = "underbutton3"
        default:
            imageName = "underbutton1" // 기본값
        }
        
        eraImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        print("🏛️ 시대 이미지 변경: \(imageName)")
    }

    public override func addView() {
        [
            backGround,
            eraImageView,
            coinImageView,
            itemLabel,
            coinLabel,
            navigationBar
        ].forEach { view.addSubview($0) }
    }

    public override func attribute() {
        view.backgroundColor = .background
        navigationBar.backgroundColor = .clear
        hideKeyboardWhenTappedAround()
        navigationBar.parentViewController = self
    }

    public override func setLayout() {
        backGround.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        eraImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(9.5)
            $0.leading.equalToSuperview().inset(20)
        }
      
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        coinLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12.5)
            $0.trailing.equalToSuperview().inset(80)
        }
        
        coinImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8.5)
            $0.trailing.equalToSuperview().inset(115)
            $0.width.height.equalTo(28)
        }
        
        itemLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(504)
            $0.leading.equalToSuperview().inset(25)
        }
    }
}
