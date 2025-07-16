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

// MARK: - Shop API
enum ShopAPI {
    case getAllItems
}

extension ShopAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2::8000")!
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
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
}

// MARK: - Shop Service with Unified Logging
class ShopService {
    static let shared = ShopService()
    
    private let provider = MoyaProvider<ShopAPI>(plugins: [
        MoyaLoggingPlugin(), // 로그인 API와 같은 로깅 플러그인 사용
        AuthPlugin()
    ])
    
    private var requestDisposeBag = DisposeBag()
    
    private init() {}
    
    func fetchAllItems() -> Single<[ShopItem]> {
        print("🟡 [ShopService] Starting API request to /all")
        
        // 토큰 존재 확인
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("🔴 [ShopService] No token found")
            return Single.error(ShopAPIError.authenticationFailed)
        }
        
        // JWT 토큰 만료 체크
        if isTokenExpired(token) {
            print("🔴 [ShopService] Token is expired")
            clearInvalidToken()
            return Single.error(ShopAPIError.tokenExpired)
        }
        
        print("🟢 [ShopService] Token exists and valid: \(token.prefix(20))...")
        
        return provider.rx.request(ShopAPI.getAllItems)
            .timeout(.seconds(30), scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                print("🟢 [ShopService] API Response received - Status: \(response.statusCode)")
            })
            .flatMap { response -> Single<[ShopItem]> in
                switch response.statusCode {
                case 200...299:
                    return self.parseShopItems(from: response.data)
                case 401:
                    print("🔴 [ShopService] 401 Unauthorized")
                    self.clearInvalidToken()
                    return Single.error(ShopAPIError.authenticationFailed)
                case 403:
                    print("🔴 [ShopService] 403 Forbidden")
                    self.clearInvalidToken()
                    return Single.error(ShopAPIError.authenticationFailed)
                case 404:
                    print("🔴 [ShopService] 404 Not Found")
                    return Single.error(ShopAPIError.endpointNotFound)
                case 500...599:
                    print("🔴 [ShopService] Server error: \(response.statusCode)")
                    return Single.error(ShopAPIError.serverError)
                default:
                    print("🔴 [ShopService] Unexpected status: \(response.statusCode)")
                    return Single.error(ShopAPIError.unexpectedError)
                }
            }
            .do(onError: { error in
                print("🔴 [ShopService] Final error: \(error)")
            })
            .catch { error in
                if error.localizedDescription.contains("cancelled") {
                    return Single.error(error)
                }
                return Single.error(ShopAPIError.networkError)
            }
    }

    // JWT 토큰 만료 체크
    private func isTokenExpired(_ token: String) -> Bool {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            print("🔴 [ShopService] Invalid JWT format")
            return true
        }
        
        let payloadPart = parts[1]
        let paddedPayload = payloadPart.padding(toLength: ((payloadPart.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        
        guard let payloadData = Data(base64Encoded: paddedPayload),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            print("🔴 [ShopService] Cannot parse token expiration")
            return true
        }
        
        let currentTime = Date().timeIntervalSince1970
        let isExpired = currentTime >= exp
        
        print("🟡 [ShopService] Token expiry check - Current: \(currentTime), Expires: \(exp), Expired: \(isExpired)")
        
        return isExpired
    }
    
    // 무효한 토큰 제거
    private func clearInvalidToken() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        print("🟡 [ShopService] Invalid token cleared")
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
            switch response.statusCode {
            case 401:
                print("🔴 [AuthPlugin] 401 Unauthorized - Token invalid")
                handleAuthenticationFailure()
            case 403:
                print("🔴 [AuthPlugin] 403 Forbidden - Access denied")
                handleAuthenticationFailure()
            default:
                break
            }
        case let .failure(error):
            if !error.localizedDescription.contains("cancelled") {
                print("🔴 [AuthPlugin] Request failed: \(error)")
            }
        }
    }
    
    private func handleAuthenticationFailure() {
        print("🔴 [AuthPlugin] Handling authentication failure")
        UserDefaults.standard.removeObject(forKey: "access_token")
        NotificationCenter.default.post(name: NSNotification.Name("AuthenticationFailed"), object: nil)
    }
}

// MARK: - Debug Helper
extension ShopService {
    func debugTokenInfo() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("🔴 [Debug] No token found")
            return
        }
        
        print("🟡 [Debug] Full token: \(token)")
        
        let parts = token.components(separatedBy: ".")
        if parts.count == 3 {
            let payloadPart = parts[1]
            let paddedPayload = payloadPart.padding(toLength: ((payloadPart.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            
            if let payloadData = Data(base64Encoded: paddedPayload),
               let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                print("🟡 [Debug] Token payload: \(payload)")
                
                if let exp = payload["exp"] as? TimeInterval {
                    let expDate = Date(timeIntervalSince1970: exp)
                    print("🟡 [Debug] Token expires at: \(expDate)")
                    print("🟡 [Debug] Current time: \(Date())")
                    print("🟡 [Debug] Is expired: \(Date() >= expDate)")
                }
            }
        }
    }
}
