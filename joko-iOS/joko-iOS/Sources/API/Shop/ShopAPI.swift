import Foundation
import RxSwift
import RxCocoa
import Moya
import RxMoya

// MARK: - Shop Item Model
struct ShopItem: Codable {
    let id: Int
    let name: String
    let price: Int
    let imageUrl: String?
    
    var displayName: String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Shop API Target
enum ShopAPI {
    case getAllItems
}

extension ShopAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }
    
    var path: String {
        switch self {
        case .getAllItems:
            return "/all"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            print("🟡 [ShopAPI] Using access token: \(token.prefix(20))...")
            headers["Authorization"] = "Bearer \(token)"
        } else {
            print("🔴 [ShopAPI] No access token found!")
        }
        
        print("🟡 [ShopAPI] Request headers: \(headers)")
        return headers
    }
}

// MARK: - Shop Service
class ShopService {
    static let shared = ShopService()
    
    private let provider = MoyaProvider<ShopAPI>(plugins: [
        NetworkLoggerPlugin(configuration: .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        )),
        AuthPlugin()
    ])
    
    // 요청 관리를 위한 DisposeBag
    private var requestDisposeBag = DisposeBag()
    
    private init() {}
    
    func fetchAllItems() -> Single<[ShopItem]> {
        print("🟡 [ShopService] Starting API request to /all")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            print("🟢 [ShopService] Token exists: \(token.prefix(20))...")
        } else {
            print("🔴 [ShopService] No token found - API will likely fail")
        }
        
        return provider.rx.request(ShopAPI.getAllItems)
            .timeout(.seconds(30), scheduler: MainScheduler.instance) // 30초 타임아웃 설정
            .do(onSuccess: { response in
                print("🟢 [ShopService] API Response received")
                print("🟢 Status code: \(response.statusCode)")
                print("🟢 Response headers: \(response.response?.allHeaderFields ?? [:])")
                
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("🟢 Response JSON:\n\(jsonString)")
                }
            })
            .flatMap { response -> Single<[ShopItem]> in
                switch response.statusCode {
                case 200...299:
                    return self.parseShopItems(from: response.data)
                case 401, 403:
                    print("🔴 [ShopService] Authentication failed - Status: \(response.statusCode)")
                    return Single.error(ShopAPIError.authenticationFailed)
                case 404:
                    print("🔴 [ShopService] Endpoint not found - Status: \(response.statusCode)")
                    return Single.error(ShopAPIError.endpointNotFound)
                case 500...599:
                    print("🔴 [ShopService] Server error - Status: \(response.statusCode)")
                    return Single.error(ShopAPIError.serverError)
                default:
                    print("🔴 [ShopService] Unexpected status code: \(response.statusCode)")
                    return Single.error(ShopAPIError.unexpectedError)
                }
            }
            .do(onError: { error in
                print("🔴 [ShopService] Final error: \(error)")
                
                // MoyaError 처리
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .underlying(let underlyingError, _):
                        print("🔴 [ShopService] Underlying error: \(underlyingError)")
                        if underlyingError.localizedDescription.contains("cancelled") {
                            print("🟡 [ShopService] Request was cancelled - this is expected behavior")
                        }
                    default:
                        print("🔴 [ShopService] Moya error: \(moyaError)")
                    }
                }
            })
            .catch { error in
                // 취소 에러인 경우 빈 배열 대신 에러 전파
                if error.localizedDescription.contains("cancelled") ||
                   error.localizedDescription.contains("explicitlyCancelled") {
                    return Single.error(error)
                }
                
                // 다른 에러의 경우 적절한 에러 타입으로 변환
                return Single.error(ShopAPIError.networkError)
            }
    }
    
    private func parseShopItems(from data: Data) -> Single<[ShopItem]> {
        if data.isEmpty {
            print("🔴 [ShopService] Empty response data")
            return Single.error(ShopAPIError.emptyResponse)
        }
        
        do {
            let items = try JSONDecoder().decode([ShopItem].self, from: data)
            print("🟢 [ShopService] Successfully decoded \(items.count) items")
            return Single.just(items)
        } catch {
            print("🔴 [ShopService] Decoding error: \(error)")
            return Single.error(ShopAPIError.decodingError)
        }
    }
    
    // 토큰 갱신 함수
    func refreshTokenIfNeeded() -> Single<Bool> {
        return Single.just(true)
    }
    
    // 진행 중인 요청 취소
    func cancelOngoingRequests() {
        requestDisposeBag = DisposeBag()
        print("🟡 [ShopService] All ongoing requests cancelled")
    }
}

// MARK: - Custom Error Types
enum ShopAPIError: Error, LocalizedError {
    case authenticationFailed
    case emptyResponse
    case tokenExpired
    case networkError
    case decodingError
    case endpointNotFound
    case serverError
    case unexpectedError
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "인증에 실패했습니다. 다시 로그인해주세요."
        case .emptyResponse:
            return "서버로부터 응답을 받지 못했습니다."
        case .tokenExpired:
            return "토큰이 만료되었습니다. 다시 로그인해주세요."
        case .networkError:
            return "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요."
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .endpointNotFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .serverError:
            return "서버에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .unexpectedError:
            return "예상치 못한 오류가 발생했습니다."
        }
    }
}

// MARK: - Custom Auth Plugin
class AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            print("🟡 [AuthPlugin] Adding Bearer token to request")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("🔴 [AuthPlugin] No token available for request")
        }
        
        return request
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            if response.statusCode == 403 {
                print("🔴 [AuthPlugin] 403 Forbidden - Token may be invalid")
                handleAuthenticationFailure()
            }
        case let .failure(error):
            print("🔴 [AuthPlugin] Request failed: \(error)")
            
            // 취소 에러가 아닌 경우에만 로그
            if !error.localizedDescription.contains("cancelled") {
                print("🔴 [AuthPlugin] Non-cancellation error: \(error)")
            }
        }
    }
    
    private func handleAuthenticationFailure() {
        print("🔴 [AuthPlugin] Handling authentication failure")
        // 토큰 제거 또는 갱신 로직
    }
}

// MARK: - JSON Response Formatter
private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}
