import Foundation
import Moya

enum UserAPI {
    case fetchUserId
    case fetchUserInfo(userId: Int)
    case changeEra(userId: Int, era: String) // 추가
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }
    
    var path: String {
        switch self {
        case .fetchUserId:
            return "/user/id"
        case .fetchUserInfo:
            return "/user/info"
        case .changeEra:
            return "/user/change"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .changeEra:
            return .post // 서버가 GET이면 .get으로 바꿔도 됨
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchUserId:
            return .requestPlain
        case .fetchUserInfo(let userId):
            return .requestParameters(
                parameters: ["userId": userId],
                encoding: URLEncoding.queryString
            )
        case .changeEra(let userId, let era):
            // 쿼리 파라미터 방식
            return .requestParameters(
                parameters: ["userId": userId, "era": era],
                encoding: URLEncoding.queryString
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

public struct UserInfoResponse: Codable {
    public let userId: Int
    public let coin: Int
    public let era: String
    public let job: String
    public let rank: String
    
    public init(userId: Int, coin: Int, era: String, job: String, rank: String) {
        self.userId = userId
        self.coin = coin
        self.era = era
        self.job = job
        self.rank = rank
    }
}
