import Foundation

// 전체 그룹 (Rank 기준으로 아이템 묶음)
struct RankItemGroup: Codable {
    let rank: String
    let items: [ShopItem]
}

// 개별 상점 아이템
struct ShopItem: Codable {
    let itemId: Int
    let name: String
    let imageUrl: String?
    let price: Int
    let userItemId: Int? // 이 줄 추가
}
