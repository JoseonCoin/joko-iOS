import Foundation
import Moya

enum QuizIdAPI {
    case fetchQuizIds
    case fetchOneQuiz(id: Int)
}

struct Quiz: Decodable {
    let quizId: Int
    let question: String
    let options: [String]
    let coin: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case quizId = "id"
        case question
        case options
        case coin
        case imageUrl
    }
}


extension QuizIdAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://localhost:8080")!
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
