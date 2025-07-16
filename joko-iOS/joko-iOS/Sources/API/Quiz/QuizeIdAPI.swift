import Moya
import Foundation

enum QuizIdAPI {
    case fetchQuizIds
}

extension QuizIdAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8000")!
    }

    var path: String {
        switch self {
        case .fetchQuizIds:
            return "/quiz/ids"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchQuizIds:
            return .get
        }
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
