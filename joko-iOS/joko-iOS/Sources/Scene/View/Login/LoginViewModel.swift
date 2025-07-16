import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire


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

    private lazy var provider: MoyaProvider<LoginAPI> = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        let session = Session(configuration: configuration)
        
        return MoyaProvider<LoginAPI>(
            session: session,
            plugins: [MoyaLoggingPlugin()]
        )
    }()

    public func transform(input: Input) -> Output {
        let isLoginEnabled = Driver.combineLatest(input.accountId, input.password) {
            !$0.isEmpty && !$1.isEmpty && $1.count >= 6
        }

        input.loginTap
            .withLatestFrom(Driver.combineLatest(input.accountId, input.password))
            .do(onNext: { id, pw in
                print("🔵 로그인 탭 이벤트 발생 - ID: \(id), PW: \(pw.count)자")
            })
            .drive(onNext: { [weak self] id, pw in
                print("🔵 로그인 함수 호출 시작")
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
        print("🟡 로그인 시작 - ID: \(accountId)")
        isLoadingSubject.onNext(true)
        print("🟡 네트워크 요청 시작")

        provider.request(.login(accountId: accountId, password: password)) { [weak self] result in
            print("🟢 네트워크 응답 받음")

            guard let self = self else {
                print("🔴 self가 nil")
                return
            }

            self.isLoadingSubject.onNext(false)

            switch result {
            case .success(let response):
                print("🟢 응답 성공 - 상태 코드: \(response.statusCode)")
                print("🟢 응답 본문: \(String(data: response.data, encoding: .utf8) ?? "없음")")

                if response.statusCode == 200 {
                    do {
                        let decoded = try JSONDecoder().decode(LoginResponse.self, from: response.data)
                        print("🟢 디코딩 성공")

                        TokenManager.shared.saveTokens(
                            accessToken: decoded.accessToken,
                            refreshToken: decoded.refreshToken
                        )

                        self.loginSuccessSubject.onNext(())

                        // ✅ 테스트용 API 호출
                        self.testFetchQuizIds()

                    } catch {
                        print("🔴 디코딩 오류: \(error)")
                        self.loginErrorSubject.onNext("응답 파싱 실패")
                    }
                }

            case .failure(let error):
                print("🔴 요청 실패")
                print("🔴 에러: \(error)")
                print("🔴 상태 코드: \(error.response?.statusCode ?? -1)")
                print("🔴 에러 응답: \(String(data: error.response?.data ?? Data(), encoding: .utf8) ?? "없음")")

                let errorMessage = self.getErrorMessage(from: error)
                self.loginErrorSubject.onNext(errorMessage)
            }
        }
    }

    private func getErrorMessage(from error: MoyaError) -> String {
        switch error {
        case .underlying(let nsError, _):
            if let urlError = nsError as? URLError {
                switch urlError.code {
                case .timedOut:
                    return "서버 연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요."
                case .notConnectedToInternet:
                    return "인터넷 연결을 확인해주세요."
                case .cannotFindHost:
                    return "서버를 찾을 수 없습니다."
                case .cannotConnectToHost:
                    return "서버에 연결할 수 없습니다."
                case .networkConnectionLost:
                    return "네트워크 연결이 끊어졌습니다."
                default:
                    return "네트워크 오류가 발생했습니다: \(urlError.localizedDescription)"
                }
            }
            return "네트워크 오류: \(nsError.localizedDescription)"
        case .requestMapping:
            return "요청 생성 중 오류가 발생했습니다."
        case .jsonMapping:
            return "응답 데이터 형식 오류"
        case .statusCode(let response):
            return "서버 오류 (상태 코드: \(response.statusCode))"
        case .stringMapping:
            return "문자열 변환 오류"
        case .objectMapping:
            return "객체 변환 오류"
        case .encodableMapping:
            return "인코딩 오류"
        case .parameterEncoding:
            return "매개변수 인코딩 오류"
        case .imageMapping:
            return "이미지 변환 오류"
        }
    }

    // MARK: - 테스트: 퀴즈 ID API 호출

    private func testFetchQuizIds() {
        let quizProvider = MoyaProvider<QuizIdAPI>()
        quizProvider.request(.fetchQuizIds) { result in
            switch result {
            case .success(let response):
                print("✅ [Test] Quiz ID API 응답 상태 코드: \(response.statusCode)")
                print("✅ [Test] 응답 본문: \(String(data: response.data, encoding: .utf8) ?? "없음")")
            case .failure(let error):
                print("❌ [Test] Quiz ID API 호출 실패: \(error.localizedDescription)")
            }
        }
    }
}

struct LoginResponse: Decodable {
    let accessToken: String
    let accessTokenExpiresAt: String
    let refreshToken: String
    let refreshTokenExpiresAt: String
}

// M
