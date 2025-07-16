import Moya
import Foundation

enum LoginAPI {
    case login(accountId: String, password: String)
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8000")!
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(accountId, password):
            return .requestParameters(
                parameters: ["accountId": accountId, "password": password],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
