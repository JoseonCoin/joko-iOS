import Foundation
import RxSwift
import RxCocoa
import Moya

public class ChangeEraViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<UserAPI>(plugins: [MoyaLoggingPlugin()])
    
    private let currentEraRelay = BehaviorRelay<String?>(value: nil)
    private let coinAmountRelay = BehaviorRelay<Int?>(value: nil)
    
    public struct Input {
        let appearTrigger: Observable<Void>
    }
    
    public struct Output {
        let currentEra: Observable<String?>
        let coinAmount: Observable<Int?>
        
        public init(currentEra: Observable<String?>, coinAmount: Observable<Int?>) {
            self.currentEra = currentEra
            self.coinAmount = coinAmount
        }
    }
    
    public init() {}
    
    public func transform(input: Input) -> Output {
        input.appearTrigger
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<(String?, Int?)> in
                guard let self = self else { return .just((nil, nil)) }
                return self.fetchUserData()
            }
            .subscribe(onNext: { [weak self] (era, coin) in
                self?.currentEraRelay.accept(era)
                self?.coinAmountRelay.accept(coin)
            })
            .disposed(by: disposeBag)
        
        return Output(
            currentEra: currentEraRelay.asObservable(),
            coinAmount: coinAmountRelay.asObservable()
        )
    }
    
    private func fetchUserData() -> Observable<(String?, Int?)> {
        print("📡 fetchUserData() 호출됨")
        
        // 먼저 userId 가져오기
        return provider.rx.request(.fetchUserId)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("✅ userId 응답 데이터: \(try? response.mapString())")
            }, onError: { error in
                print("❌ userId 에러 발생: \(error)")
            })
            .map(User.self)
            .map { $0.userId }
            .asObservable()
            .flatMapLatest { [weak self] userId -> Observable<(String?, Int?)> in
                guard let self = self else { return .just((nil, nil)) }
                return self.fetchUserInfo(userId: userId)
            }
            .catchAndReturn((nil, nil))
    }
    
    private func fetchUserInfo(userId: Int) -> Observable<(String?, Int?)> {
        print("📡 fetchUserInfo() 호출됨 - userId: \(userId)")
        
        return provider.rx.request(.fetchUserInfo(userId: userId))
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("✅ userInfo 응답 데이터: \(try? response.mapString())")
            }, onError: { error in
                print("❌ userInfo 에러 발생: \(error)")
            })
            .map { try? $0.map(UserInfoResponse.self) }
            .map { userInfo -> (String?, Int?) in
                let era = userInfo?.era
                let coin = userInfo?.coin
                print("📊 파싱 결과 - era: \(era ?? "nil"), coin: \(coin ?? -1)")
                return (era, coin)
            }
            .asObservable()
            .catchAndReturn((nil, nil))
    }
}
