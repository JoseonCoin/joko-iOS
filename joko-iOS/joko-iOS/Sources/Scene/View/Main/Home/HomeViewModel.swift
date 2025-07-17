import Foundation
import RxSwift
import RxCocoa
import Moya

public class HomeViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<UserAPI>(plugins: [MoyaLoggingPlugin()])
    
    private let userIdRelay = BehaviorRelay<Int?>(value: nil)
    private let userInfoRelay = BehaviorRelay<UserInfoResponse?>(value: nil)
    
    public var userId: Int? {
        return userIdRelay.value
    }
    
    var userInfo: UserInfoResponse? {
        return userInfoRelay.value
    }
    
    public struct Input {
        let appearTrigger: Observable<Void>
    }
    
    public struct Output {
        let userId: Observable<Int?>
        let userInfo: Observable<UserInfoResponse?>
    }
    
    public init() {}
    
    public func transform(input: Input) -> Output {
        input.appearTrigger
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 중복 호출 방지
            .flatMapLatest { [weak self] _ -> Observable<Int?> in
                guard let self = self else { return .just(nil) }
                return self.fetchUserId()
            }
            .bind(to: userIdRelay)
            .disposed(by: disposeBag)
        
        // userId가 변경될 때마다 userInfo 가져오기
        userIdRelay
            .compactMap { $0 } // nil이 아닌 경우만
            .distinctUntilChanged() // 같은 userId 중복 호출 방지
            .flatMapLatest { [weak self] userId -> Observable<UserInfoResponse?> in
                guard let self = self else { return .just(nil) }
                return self.fetchUserInfo(userId: userId)
            }
            .bind(to: userInfoRelay)
            .disposed(by: disposeBag)
        
        return Output(
            userId: userIdRelay.asObservable(),
            userInfo: userInfoRelay.asObservable()
        )
    }
    
    private func fetchUserId() -> Observable<Int?> {
        print("📡 fetchUserId() 호출됨")
        return provider.rx.request(.fetchUserId)
            .timeout(.seconds(10), scheduler: MainScheduler.instance) // 타임아웃 설정
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
            .timeout(.seconds(10), scheduler: MainScheduler.instance) // 타임아웃 설정
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
