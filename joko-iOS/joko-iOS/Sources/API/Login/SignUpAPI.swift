import Foundation
import Moya

public enum SignUpAPI {
    case signUp(username: String, accountId: String, password: String)
}

extension SignUpAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://your-api-base-url.com")! // 실제 베이스 URL로 변경
    }
    
    public var path: String {
        switch self {
        case .signUp:
            return "/signup" // 실제 회원가입 API 경로로 변경
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .signUp:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .signUp(let username, let accountId, let password):
            let parameters: [String: Any] = [
                "username": username,
                "accountId": accountId,
                "password": password
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
