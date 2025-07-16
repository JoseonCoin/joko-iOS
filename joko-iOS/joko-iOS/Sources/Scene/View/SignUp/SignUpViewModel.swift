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
        print("🟡 회원가입 시작 - ID: \(accountId)")
        isLoadingSubject.onNext(true)
        
        provider.request(.signUp(username: username, accountId: accountId, password: password)) { [weak self] result in
            print("🟢 회원가입 네트워크 응답 받음")
            
            guard let self = self else {
                print("🔴 self가 nil")
                return
            }
            
            self.isLoadingSubject.onNext(false)
            
            switch result {
            case .success(let response):
                print("🟢 회원가입 응답 성공 - 상태 코드: \(response.statusCode)")
                print("🟢 응답 본문: \(String(data: response.data, encoding: .utf8) ?? "없음")")
                
                switch response.statusCode {
                case 200, 201:
                    // 회원가입 성공 시 응답에 토큰이 포함되어 있는지 확인
                    do {
                        let decoded = try JSONDecoder().decode(SignUpResponse.self, from: response.data)
                        print("🟢 회원가입 디코딩 성공")

                        // ✅ TokenManager를 사용하여 토큰 저장
                        TokenManager.shared.saveTokens(
                            accessToken: decoded.accessToken,
                            refreshToken: decoded.refreshToken
                        )

                        // ✅ 성공 이벤트 전달
                        self.signUpSuccessSubject.onNext(())
                    } catch {
                        print("🔴 회원가입 디코딩 오류: \(error)")
                        // 토큰이 없는 경우에도 성공으로 처리 (서버 정책에 따라)
                        self.signUpSuccessSubject.onNext(())
                    }
                case 400:
                    self.signUpErrorSubject.onNext("요청 데이터가 잘못되었습니다.")
                case 409:
                    self.signUpErrorSubject.onNext("이미 사용 중인 아이디입니다.")
                case 500:
                    self.signUpErrorSubject.onNext("서버 오류가 발생했습니다.")
                default:
                    self.signUpErrorSubject.onNext("회원가입에 실패했습니다.")
                }
            case .failure(let error):
                print("🔴 회원가입 요청 실패")
                print("🔴 에러: \(error)")
                self.signUpErrorSubject.onNext("네트워크 오류: \(error.localizedDescription)")
            }
        }
    }
}

// 회원가입 응답 모델 (서버가 토큰을 반환하는 경우)
struct SignUpResponse: Decodable {
    let accessToken: String
    let accessTokenExpiresAt: String?
    let refreshToken: String
    let refreshTokenExpiresAt: String?
}
