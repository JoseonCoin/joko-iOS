import Foundation
import Moya

enum ItemAPI {
    case fetchUserItems(userId: Int)
}

extension ItemAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }
    
    var path: String {
        switch self {
        case .fetchUserItems:
            return "/item/users"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .fetchUserItems(let userId):
            return .requestParameters(
                parameters: ["userId": userId],
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

// MARK: - Response Models
public struct UserItemsResponse: Codable {
    public let job: String
    public let totalCount: Int
    public let ownedCount: Int
    public let items: [ItemInfo]
    
    public init(job: String, totalCount: Int, ownedCount: Int, items: [ItemInfo]) {
        self.job = job
        self.totalCount = totalCount
        self.ownedCount = ownedCount
        self.items = items
    }
}

public struct ItemInfo: Codable {
    public let itemId: Int
    public let name: String
    public let imageUrl: String
    public let owned: Bool
    
    public init(itemId: Int, name: String, imageUrl: String, owned: Bool) {
        self.itemId = itemId
        self.name = name
        self.imageUrl = imageUrl
        self.owned = owned
    }
}
