import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Moya

final class ShopViewController: BaseViewController<ShopViewModel> {
    private let provider = MoyaProvider<ShopAPI>(plugins: [NetworkLoggerPlugin()])
    
    private let titleLabel = UILabel().then {
        $0.font = .JokoFont(.title2)
        $0.textColor = .white1
        $0.text = "상점"
    }

    private let explainLabel = UILabel().then {
        $0.text = "신분 상승을 위한 아이템을 구매하거나 판매하세요."
        $0.font = .JokoFont(.body3)
        $0.textColor = .gray300
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.identifier)
        return collectionView
    }()

    private let refreshControl = UIRefreshControl().then {
        $0.tintColor = .white1
    }

    private var shopItems: [ShopItem] = []
    private var isFirstLoad = true
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.0

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()

    public override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewDidLoadSubject.onNext(())
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isFirstLoad && shouldMakeRequest() {
            refreshSubject.onNext(())
        }
        isFirstLoad = false
    }

    private func shouldMakeRequest() -> Bool {
        guard let lastTime = lastRequestTime else {
            lastRequestTime = Date()
            return true
        }

        let timeSinceLastRequest = Date().timeIntervalSince(lastTime)
        if timeSinceLastRequest >= minimumRequestInterval {
            lastRequestTime = Date()
            return true
        }

        return false
    }

    public override func attribute() {
        super.attribute()
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    public override func addView() {
        [titleLabel, explainLabel, collectionView].forEach { view.addSubview($0) }
    }

    public override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.equalToSuperview().inset(20)
        }

        explainLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(explainLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindViewModel() {
        let input = ShopViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            refreshTrigger: refreshSubject.asObservable(),
            itemSelected: itemSelectedSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.shopItems
            .drive(onNext: { [weak self] items in
                self?.shopItems = items
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)

        output.selectedItem
            .drive(onNext: { [weak self] item in
                guard let self = self, let item = item else { return }
                self.showBuyOrSellActionSheet(for: item)
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshData() {
        guard shouldMakeRequest() else {
            refreshControl.endRefreshing()
            return
        }
        refreshSubject.onNext(())
    }

    private func showBuyOrSellActionSheet(for item: ShopItem) {
        let alert = UIAlertController(title: item.name, message: "이 아이템을 어떻게 하시겠어요?", preferredStyle: .actionSheet)

        // 구매하기 옵션은 항상 표시
        alert.addAction(UIAlertAction(title: "구매하기", style: .default, handler: { _ in
            self.buyItem(item)
        }))

        // 판매하기 옵션은 userItemId가 있을 때만 표시
        if let userItemId = item.userItemId, userItemId > 0 {
            alert.addAction(UIAlertAction(title: "판매하기", style: .destructive, handler: { _ in
                self.sellItem(item)
            }))
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad에서 actionSheet 사용 시 필요한 설정
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }

    private func buyItem(_ item: ShopItem) {
        // 실제 사용자 ID를 가져오는 로직으로 변경해야 합니다
        let userId = getCurrentUserId()
        
        ShopService.shared.buyItem(userId: userId, itemId: item.itemId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] userItemId in
                print("🟢 구매 성공 - userItemId: \(userItemId)")
                self?.showAlert(title: "구매 완료", message: "\(item.name)을 구매했습니다.")
                self?.refreshSubject.onNext(())
            }, onFailure: { [weak self] error in
                print("🔴 구매 실패: \(error)")
                self?.handleBuyError(error, itemName: item.name)
            })
            .disposed(by: disposeBag)
    }

    private func sellItem(_ item: ShopItem) {
        guard let userItemId = item.userItemId else {
            showAlert(title: "판매 불가", message: "판매 가능한 아이템이 아닙니다.")
            return
        }

        // 판매 확인 Alert 추가
        let confirmAlert = UIAlertController(
            title: "판매 확인",
            message: "\(item.name)을 정말 판매하시겠습니까?",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "판매", style: .destructive) { _ in
            self.performSellItem(userItemId: userItemId, itemName: item.name)
        })
        
        present(confirmAlert, animated: true)
    }
    
    private func performSellItem(userItemId: Int, itemName: String) {
        ShopService.shared.sellItem(userItemId: userItemId)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                print("🟢 판매 성공 - userItemId: \(userItemId)")
                self?.showAlert(title: "판매 완료", message: "\(itemName)을 판매했습니다.")
                self?.refreshSubject.onNext(())
            }, onError: { [weak self] error in
                print("🔴 판매 실패: \(error)")
                self?.handleSellError(error, itemName: itemName)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserId() -> Int {
        // TODO: 실제 사용자 ID를 가져오는 로직 구현
        // UserDefaults, KeyChain, 또는 다른 저장소에서 가져오기
        return UserDefaults.standard.integer(forKey: "user_id")
    }
    
    private func handleBuyError(_ error: Error, itemName: String) {
        var message = "구매에 실패했습니다."
        
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                if response.statusCode == 400 {
                    message = "잔액이 부족하거나 이미 소유한 아이템입니다."
                } else if response.statusCode == 401 {
                    message = "로그인이 필요합니다."
                } else {
                    message = "서버 오류가 발생했습니다. (코드: \(response.statusCode))"
                }
            case .underlying(let error, _):
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    message = "인터넷 연결을 확인해주세요."
                } else {
                    message = "네트워크 오류가 발생했습니다."
                }
            default:
                message = error.localizedDescription
            }
        }
        
        showAlert(title: "구매 실패", message: message)
    }
    
    private func handleSellError(_ error: Error, itemName: String) {
        var message = "판매에 실패했습니다."
        
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                if response.statusCode == 400 {
                    message = "판매할 수 없는 아이템입니다."
                } else if response.statusCode == 401 {
                    message = "로그인이 필요합니다."
                } else if response.statusCode == 404 {
                    message = "아이템을 찾을 수 없습니다."
                } else {
                    message = "서버 오류가 발생했습니다. (코드: \(response.statusCode))"
                }
            case .underlying(let error, _):
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    message = "인터넷 연결을 확인해주세요."
                } else {
                    message = "네트워크 오류가 발생했습니다."
                }
            default:
                message = error.localizedDescription
            }
        }
        
        showAlert(title: "판매 실패", message: message)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ShopViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCollectionViewCell.identifier, for: indexPath) as? ShopCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = shopItems[indexPath.item]
        cell.configure(with: item)
        // 판매하기 버튼 콜백 할당
        cell.onSellButtonTapped = { [weak self] in
            self?.sellItem(item)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let availableWidth = collectionView.frame.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelectedSubject.onNext(indexPath)
    }
}
