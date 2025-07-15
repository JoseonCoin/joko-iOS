import Foundation
import RxSwift
import RxCocoa
import Moya

public class SignUpViewModel: BaseViewModel {
    
    public struct Input {
        let username: Driver<String>
        let accountId: Driver<String>
        let password: Driver<String>
        let signUpTap: Driver<Void>
    }
    
    public struct Output {
        let isSignUpEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let signUpSuccess: Driver<Void>
        let signUpError: Driver<String>
    }
    
    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let signUpSuccessSubject = PublishSubject<Void>()
    private let signUpErrorSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<SignUpAPI>(plugins: [MoyaLoggingPlugin()])
    
    public func transform(input: Input) -> Output {
        let isSignUpEnabled = Driver.combineLatest(
            input.username,
            input.accountId,
            input.password
        ) { username, accountId, password in
            return !username.isEmpty && !accountId.isEmpty && password.count >= 8
        }

        input.signUpTap
            .withLatestFrom(Driver.combineLatest(input.username, input.accountId, input.password))
            .drive(onNext: { [weak self] username, accountId, password in
                self?.signUp(username: username, accountId: accountId, password: password)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isSignUpEnabled: isSignUpEnabled,
            isLoading: isLoadingSubject.asDriver(onErrorJustReturn: false),
            signUpSuccess: signUpSuccessSubject.asDriver(onErrorJustReturn: ()),
            signUpError: signUpErrorSubject.asDriver(onErrorJustReturn: "알 수 없는 오류 발생")
        )
    }
    
    private func signUp(username: String, accountId: String, password: String) {
        isLoadingSubject.onNext(true)
        
        provider.request(.signUp(username: username, accountId: accountId, password: password)) { [weak self] result in
            self?.isLoadingSubject.onNext(false)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 201:
                    self?.signUpSuccessSubject.onNext(())
                case 400:
                    self?.signUpErrorSubject.onNext("요청 데이터가 잘못되었습니다.")
                case 500:
                    self?.signUpErrorSubject.onNext("서버 오류가 발생했습니다.")
                default:
                    self?.signUpErrorSubject.onNext("회원가입에 실패했습니다.")
                }
            case .failure(let error):
                self?.signUpErrorSubject.onNext("네트워크 오류: \(error.localizedDescription)")
            }
        }
    }
}
