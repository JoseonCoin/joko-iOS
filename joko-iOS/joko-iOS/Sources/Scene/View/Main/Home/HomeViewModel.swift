import Foundation
import RxSwift
import RxCocoa
import Moya

public class HomeViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<UserAPI>(plugins: [MoyaLoggingPlugin()])
    private let itemProvider = MoyaProvider<ItemAPI>(plugins: [MoyaLoggingPlugin()])

    private let userIdRelay = BehaviorRelay<Int?>(value: nil)
    private let userInfoRelay = BehaviorRelay<UserInfoResponse?>(value: nil)
    private let userItemsRelay = BehaviorRelay<UserItemsResponse?>(value: nil)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    public struct Input {
        let appearTrigger: Observable<Void>
    }

    public struct Output {
        let userId: Observable<Int?>
        let userInfo: Observable<UserInfoResponse?>
        let userItems: Observable<UserItemsResponse?>
        let isLoading: Observable<Bool>
    }

    public init() {}

    public func transform(input: Input) -> Output {
        input.appearTrigger
            
            .do(onNext: { [weak self] in
                print("🔄 홈 화면 나타남 - 데이터 새로고침 시작")
                self?.isLoadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<(Int?, UserInfoResponse?, UserItemsResponse?)> in
                guard let self = self else { return .just((nil, nil, nil)) }

                return self.fetchUserId()
                    .flatMapLatest { userId -> Observable<(Int?, UserInfoResponse?, UserItemsResponse?)> in
                        guard let userId = userId else {
                            print("❌ userId가 없어서 다른 API 호출 불가")
                            return .just((nil, nil, nil))
                        }

                        let userInfoObservable = self.fetchUserInfo(userId: userId)
                        let userItemsObservable = self.fetchUserItems(userId: userId)

                        return Observable.zip(userInfoObservable, userItemsObservable)
                            .map { (userInfo, userItems) in
                                return (userId, userInfo, userItems)
                            }
                    }
            }
            .do(onNext: { [weak self] (userId, userInfo, userItems) in
                self?.isLoadingRelay.accept(false)
                print("✅ 모든 API 호출 완료")
                print("   - userId: \(userId ?? 0)")
                print("   - userInfo: \(userInfo != nil ? "있음" : "없음")")
                print("   - userItems: \(userItems != nil ? "있음" : "없음")")

                self?.userIdRelay.accept(userId)
                self?.userInfoRelay.accept(userInfo)
                self?.userItemsRelay.accept(userItems)
            })
            .subscribe()
            .disposed(by: disposeBag)

        return Output(
            userId: userIdRelay.asObservable(),
            userInfo: userInfoRelay.asObservable(),
            userItems: userItemsRelay.asObservable(),
            isLoading: isLoadingRelay.asObservable()
        )
    }

    private func fetchUserId() -> Observable<Int?> {
        print("📡 fetchUserId() 호출됨")
        return provider.rx.request(.fetchUserId)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("✅ userId 응답 데이터: \(try? response.mapString())")
            }, onError: { error in
                print("❌ userId 에러 발생: \(error)")
                self.handleNetworkError(error)
            })
            .map(User.self)
            .map { $0.userId }
            .asObservable()
            .catchAndReturn(nil)
    }

    private func fetchUserInfo(userId: Int) -> Observable<UserInfoResponse?> {
        print("📡 fetchUserInfo() 호출됨 - userId: \(userId)")
        return provider.rx.request(.fetchUserInfo(userId: userId))
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("✅ userInfo 응답 데이터: \(try? response.mapString())")
            }, onError: { error in
                print("❌ userInfo 에러 발생: \(error)")
                self.handleNetworkError(error)
            })
            .map { try? $0.map(UserInfoResponse.self) }
            .asObservable()
            .catchAndReturn(nil)
    }

    private func fetchUserItems(userId: Int) -> Observable<UserItemsResponse?> {
        print("📡 fetchUserItems() 호출됨 - userId: \(userId)")
        return itemProvider.rx.request(.fetchUserItems(userId: userId))
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("✅ userItems 응답 데이터: \(try? response.mapString())")
            }, onError: { error in
                print("❌ userItems 에러 발생: \(error)")
                self.handleNetworkError(error)
            })
            .map { try? $0.map(UserItemsResponse.self) }
            .asObservable()
            .catchAndReturn(nil)
    }

    private func handleNetworkError(_ error: Error) {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .underlying(let nsError, _):
                if let urlError = nsError as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        print("🚫 인터넷 연결 없음")
                    case .timedOut:
                        print("⏰ 요청 시간 초과")
                    case .cannotConnectToHost:
                        print("🔌 서버 연결 실패 - 서버가 실행 중인지 확인하세요")
                    default:
                        print("🌐 네트워크 에러: \(urlError.localizedDescription)")
                    }
                }
            default:
                print("📡 API 에러: \(moyaError.localizedDescription)")
            }
        }
    }
}
