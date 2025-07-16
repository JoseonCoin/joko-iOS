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
    
    // MARK: - Request State Management
    private var isFirstLoad = true
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.0 // 1초 간격으로 요청 제한

    // MARK: - Reactive Properties
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewDidLoadSubject.onNext(())
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isFirstLoad && shouldMakeRequest() {
            print("🟡 [ShopViewController] Refreshing data on viewWillAppear")
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
        
        print("🟡 [ShopViewController] Request blocked - too soon (interval: \(timeSinceLastRequest)s)")
        return false
    }

    // MARK: - Setup
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

    // MARK: - Bind ViewModel
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
                // 취소 에러는 무시
                if !error.contains("cancelled") && !error.contains("explicitlyCancelled") {
                    self?.showAlert(title: "오류", message: error)
                }
            })
            .disposed(by: disposeBag)

        output.selectedItem
            .drive(onNext: { [weak self] item in
                print("Selected item: \(item?.displayName ?? "None")")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc private func refreshData() {
        guard shouldMakeRequest() else {
            refreshControl.endRefreshing()
            return
        }
        
        print("🟡 [ShopViewController] Manual refresh triggered")
        refreshSubject.onNext(())
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Collection View Data Source
extension ShopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCollectionViewCell.identifier, for: indexPath) as? ShopCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = shopItems[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - Collection View Delegate Flow Layout
extension ShopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let availableWidth = collectionView.frame.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }
}

// MARK: - Collection View Delegate
extension ShopViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelectedSubject.onNext(indexPath)

        if let cell = collectionView.cellForItem(at: indexPath) as? ShopCollectionViewCell {
            cell.setSelected(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell.setSelected(false)
            }
        }
    }
}
