import Foundation
import RxSwift
import RxCocoa
import Moya

public class LoginViewModel: BaseViewModel {
    public struct Input {
        let accountId: Driver<String>
        let password: Driver<String>
        let loginTap: Driver<Void>
        let signUpTap: Driver<Void>
    }

    public struct Output {
        let isLoginEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let loginSuccess: Driver<Void>
        let loginError: Driver<String>
        let signUpTap: Driver<Void>
    }

    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let loginSuccessSubject = PublishSubject<Void>()
    private let loginErrorSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<LoginAPI>(plugins: [MoyaLoggingPlugin()])

    public func transform(input: Input) -> Output {
        let isLoginEnabled = Driver.combineLatest(input.accountId, input.password) {
            !$0.isEmpty && !$1.isEmpty && $1.count >= 6
        }

        input.loginTap
            .withLatestFrom(Driver.combineLatest(input.accountId, input.password))
            .drive(onNext: { [weak self] id, pw in
                self?.login(accountId: id, password: pw)
            })
            .disposed(by: disposeBag)

        return Output(
            isLoginEnabled: isLoginEnabled,
            isLoading: isLoadingSubject.asDriver(onErrorJustReturn: false),
            loginSuccess: loginSuccessSubject.asDriver(onErrorJustReturn: ()),
            loginError: loginErrorSubject.asDriver(onErrorJustReturn: "알 수 없는 오류 발생"),
            signUpTap: input.signUpTap
        )
    }

    private func login(accountId: String, password: String) {
        isLoadingSubject.onNext(true)
        provider.request(.login(accountId: accountId, password: password)) { [weak self] result in
            self?.isLoadingSubject.onNext(false)
            switch result {
            case .success(let response):
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data) as? [String: Any]
                    if let token = json?["token"] as? String {
                        UserDefaults.standard.set(token, forKey: "access_token")
                        self?.loginSuccessSubject.onNext(())
                    } else {
                        self?.loginErrorSubject.onNext("토큰 없음")
                    }
                } catch {
                    self?.loginErrorSubject.onNext("응답 파싱 실패")
                }
            case .failure:
                self?.loginErrorSubject.onNext("로그인 요청 실패")
            }
        }
    }
}
