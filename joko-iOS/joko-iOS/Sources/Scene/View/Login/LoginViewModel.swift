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
            guard let self = self else { return }
            self.isLoadingSubject.onNext(false)

            switch result {
            case .success(let response):
                print("응답 상태 코드:", response.statusCode)
                print("응답 본문:", String(data: response.data, encoding: .utf8) ?? "없음")

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: response.data)

                    UserDefaults.standard.set(decoded.accessToken, forKey: "access_token")
                    UserDefaults.standard.set(decoded.refreshToken, forKey: "refresh_token")

                    self.loginSuccessSubject.onNext(())
                } catch {
                    print("디코딩 오류:", error)
                    self.loginErrorSubject.onNext("응답 파싱 실패")
                }

            case .failure(let error):
                print("요청 실패 상태 코드:", error.response?.statusCode ?? -1)
                print("에러 응답:", String(data: error.response?.data ?? Data(), encoding: .utf8) ?? "없음")
                self.loginErrorSubject.onNext("로그인 요청 실패")
            }
        }
    }

}
