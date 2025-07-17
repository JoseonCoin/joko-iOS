import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher

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
    
    // 아이템 섹션 컨테이너
    private let itemContainerView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 15
    }
    
    private let itemTitleLabel = UILabel().then {
        $0.font = UIFont.chosunFont(size: 16)
        $0.text = "천민이 획득한 아이템"
        $0.textColor = .white
    }
    
    private let itemCountLabel = UILabel().then {
        $0.font = UIFont.chosunFont(size: 14)
        $0.text = "(0/0)"
        $0.textColor = .lightGray
    }
    
    private let itemCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCell")
        return collectionView
    }()
    
    private let appearTrigger = PublishRelay<Void>()
    private var userItems: [ItemInfo] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bind()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 viewWillAppear - 홈 화면 나타남")
        appearTrigger.accept(())
    }
    
    private func setupCollectionView() {
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
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
        
        // 아이템 정보 바인딩
        output.userItems
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] userItems in
                print("✅ 아이템 정보: \(userItems)")
                self?.updateItemsUI(with: userItems)
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
            itemCountLabel.text = "(0/0)"
            print("🔄 로딩 중...")
        }
    }
    
    private func updateUI(with userInfo: UserInfoResponse) {
        print("🪙 코인: \(userInfo.coin)")
        print("🏛️ 시대: \(userInfo.era)")
        print("👨‍💼 직업: \(userInfo.job)")
        print("🎖️ 계급: \(userInfo.rank)")
        
        itemTitleLabel.text = "\(userInfo.rank)이 획득한 아이템"
        coinLabel.text = "\(userInfo.coin)"
        updateBackgroundImage(for: userInfo.job)
        updateEraImage(for: userInfo.era)
    }
    
    private func updateItemsUI(with userItems: UserItemsResponse) {
        self.userItems = userItems.items
        itemCountLabel.text = "(\(userItems.ownedCount)/\(userItems.totalCount))"
        
        DispatchQueue.main.async {
            self.itemCollectionView.reloadData()
        }
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
            imageName = "underbutton1"
        }
        
        eraImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        print("🏛️ 시대 이미지 변경: \(imageName)")
    }

    public override func addView() {
        [
            backGround,
            eraImageView,
            coinImageView,
            coinLabel,
            navigationBar,
            itemContainerView
        ].forEach { view.addSubview($0) }
        
        [
            itemTitleLabel,
            itemCountLabel,
            itemCollectionView
        ].forEach { itemContainerView.addSubview($0) }
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
        
        itemContainerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(140)
        }
        
        itemTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.equalToSuperview().inset(15)
        }
        
        itemCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(itemTitleLabel)
            $0.leading.equalTo(itemTitleLabel.snp.trailing).offset(5)
        }
        
        itemCollectionView.snp.makeConstraints {
            $0.top.equalTo(itemTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        let item = userItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: - ItemCollectionViewCell
class ItemCollectionViewCell: UICollectionViewCell {
    private let itemImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let itemNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private let overlayView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [itemImageView, overlayView, itemNameLabel].forEach { contentView.addSubview($0) }
        
        itemImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        overlayView.snp.makeConstraints {
            $0.edges.equalTo(itemImageView)
        }
        
        itemNameLabel.snp.makeConstraints {
            $0.top.equalTo(itemImageView.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(with item: ItemInfo) {
        itemNameLabel.text = item.name
        
        // 아이템 소유 여부에 따른 UI 업데이트
        if item.owned {
            overlayView.isHidden = true
            itemImageView.alpha = 1.0
        } else {
            overlayView.isHidden = false
            itemImageView.alpha = 0.5
        }
        
        // 이미지 로드 (Kingfisher 사용)
        if let url = URL(string: item.imageUrl) {
            itemImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder_item"))
        } else {
            itemImageView.image = UIImage(named: "placeholder_item")
        }
    }
}
