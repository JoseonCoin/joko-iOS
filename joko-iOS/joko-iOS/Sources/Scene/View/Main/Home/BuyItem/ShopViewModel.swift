import UIKit
import Moya
import SnapKit
import Then
import RxSwift
import RxCocoa

public class ShopViewModel: BaseViewModel {
    private let provider = MoyaProvider<ShopAPI>(plugins: [NetworkLoggerPlugin()])

    private let shopService = ShopService.shared
    private let disposeBag = DisposeBag()

    private var currentRequest: Disposable?
    
    public struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTrigger: Observable<Void>
        let itemSelected: Observable<IndexPath>
    }
    
    public struct Output {
        let shopItems: Driver<[ShopItem]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
        let selectedItem: Driver<ShopItem?>
    }
    
    // MARK: - Private Properties
    private let shopItemsRelay = BehaviorRelay<[ShopItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let selectedItemRelay = BehaviorRelay<ShopItem?>(value: nil)
    
    public init() {
        // 초기화 코드
    }
    
    public func transform(input: Input) -> Output {
        let loadTrigger = Observable.merge(
            input.viewDidLoad,
            input.refreshTrigger
        )

        loadTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.loadShopItems()
            })
            .disposed(by: disposeBag)

        input.itemSelected
            .withLatestFrom(shopItemsRelay) { indexPath, items in
                return items.indices.contains(indexPath.item) ? items[indexPath.item] : nil
            }
            .bind(to: selectedItemRelay)
            .disposed(by: disposeBag)
        
        return Output(
            shopItems: shopItemsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: ""),
            selectedItem: selectedItemRelay.asDriver()
        )
    }
    
    // MARK: - Private Methods
    private func loadShopItems() {
        // 기존 요청이 있으면 취소
        currentRequest?.dispose()
        
        print("🟡 [ShopViewModel] Starting new request")
        isLoadingRelay.accept(true)
        
        currentRequest = shopService.fetchAllItems()
            .subscribe(
                onSuccess: { [weak self] rankItemGroups in
                    print(" [ShopViewModel] Successfully loaded \(rankItemGroups.count) rank groups")
                    let allItems = rankItemGroups.flatMap { $0.items }
                    self?.isLoadingRelay.accept(false)
                    self?.shopItemsRelay.accept(allItems)
                },
                onFailure: { [weak self] error in
                    print("🔴 [ShopViewModel] Load failed: \(error)")
                    self?.isLoadingRelay.accept(false)
                    
                    // 취소 에러가 아닌 경우에만 에러 표시
                    if let isCancelled = self?.isCancellationError(error), !isCancelled {
                        self?.errorRelay.accept(error.localizedDescription)
                    }
                }
            )
    }
    
    private func isCancellationError(_ error: Error) -> Bool {
        let errorString = error.localizedDescription
        return errorString.contains("cancelled") ||
               errorString.contains("explicitlyCancelled") ||
               errorString.contains("canceled")
    }
    
    // MARK: - Public Methods
    public func refreshShopItems() {
        loadShopItems()
    }
    
    public func selectItem(at indexPath: IndexPath) {
        let items = shopItemsRelay.value
        guard items.indices.contains(indexPath.item) else { return }
        selectedItemRelay.accept(items[indexPath.item])
    }
    
    public func clearSelection() {
        selectedItemRelay.accept(nil)
    }
    
    // MARK: - Cleanup
    deinit {
        currentRequest?.dispose()
        print("🟡 [ShopViewModel] Deinitialized")
    }
}
