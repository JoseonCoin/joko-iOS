import Foundation
import Moya

enum QuizAPI {
    case fetchQuizIds
    case fetchOneQuiz(id: Int)
    case postQuizSubmit(quizId: Int, selectedIndex: Int, userId: Int)
}

struct Quiz: Decodable {
    let quizId: Int
    let question: String
    let options: [String]
    let coin: Int
    let imageUrl: String?  // 옵셔널로 변경
    
    enum CodingKeys: String, CodingKey {
        case quizId = "id"
        case question
        case options
        case coin
        case imageUrl
    }
}

struct QuizSubmitRequest: Codable {
    let quizId: Int
    let selectedIndex: Int
}

struct QuizSubmitResponse: Codable {
    let correct: Bool
    let correctAnswer: String
    let explanation: String
    let coinReward: Int
}

extension QuizAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }
    
    var path: String {
        switch self {
        case .fetchQuizIds:
            return "/quiz/ids"
        case .fetchOneQuiz(let id):
            return "/quiz/\(id)"
        case .postQuizSubmit:
            return "/quiz/submit"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchQuizIds, .fetchOneQuiz:
            return .get
        case .postQuizSubmit:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .fetchQuizIds, .fetchOneQuiz:
            return .requestPlain
        case .postQuizSubmit(let quizId, let selectedIndex, let userId):
            let submitRequest: [String: Any] = [
                "quizId": quizId,
                "selectedIndex": selectedIndex
            ]
            return .requestCompositeParameters(
                bodyParameters: submitRequest,
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["id": userId]
            )
        }
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
