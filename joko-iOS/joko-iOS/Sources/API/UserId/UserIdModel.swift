import Foundation

struct User: Decodable {
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
    }
}
