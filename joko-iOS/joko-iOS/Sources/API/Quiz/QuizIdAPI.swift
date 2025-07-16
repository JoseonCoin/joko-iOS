import Foundation
import Moya

enum QuizIdAPI {
    case fetchQuizIds
    case fetchOneQuiz(id: Int)
}

struct Quiz: Codable {
    let quizId: Int
    let question: String
    let options: [String]
    let coin: Int
    let imageurl: String
}

extension QuizIdAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }

    var path: String {
        switch self {
        case .fetchQuizIds:
            return "/quiz/ids"
        case .fetchOneQuiz(let id):
            return "/quiz/\(id)"
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
