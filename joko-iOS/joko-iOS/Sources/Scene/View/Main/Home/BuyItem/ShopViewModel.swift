import Foundation
import RxSwift
import RxCocoa
import Moya

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

    private let shopItemsRelay = BehaviorRelay<[ShopItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let selectedItemRelay = BehaviorRelay<ShopItem?>(value: nil)

    public init() {}

    public func transform(input: Input) -> Output {
        let loadTrigger = Observable.merge(input.viewDidLoad, input.refreshTrigger)

        loadTrigger
            .subscribe(onNext: { [weak self] in self?.loadShopItems() })
            .disposed(by: disposeBag)

        input.itemSelected
            .withLatestFrom(shopItemsRelay) { indexPath, items in
                items.indices.contains(indexPath.item) ? items[indexPath.item] : nil
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

    private func loadShopItems() {
        currentRequest?.dispose()
        isLoadingRelay.accept(true)

        currentRequest = shopService.fetchAllItems()
            .subscribe(onSuccess: { [weak self] rankGroups in
                let allItems = rankGroups.flatMap { $0.items }
                self?.shopItemsRelay.accept(allItems)
                self?.isLoadingRelay.accept(false)
            }, onFailure: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                if !(self?.isCancellationError(error) ?? false) {
                    self?.errorRelay.accept(error.localizedDescription)
                }
            })
    }

    private func isCancellationError(_ error: Error) -> Bool {
        let errorString = error.localizedDescription.lowercased()
        return errorString.contains("cancelled") || errorString.contains("canceled")
    }

    deinit {
        currentRequest?.dispose()
    }
}
