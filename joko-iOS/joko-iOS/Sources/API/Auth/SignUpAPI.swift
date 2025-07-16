import Foundation
import Moya

public enum SignUpAPI {
    case signUp(username: String, accountId: String, password: String)
}

extension SignUpAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
        case .signUp:
            return "/auth/signup"
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
        var headers = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

}
