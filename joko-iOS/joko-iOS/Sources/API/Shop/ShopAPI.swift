import Foundation
import RxSwift
import Moya
import RxMoya

// MARK: - 모델

struct ShopItem: Codable {
    let itemId: Int
    let name: String
    let price: Int
    let imageUrl: String?

    var displayName: String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct RankItemGroup: Codable {
    let rank: String
    let items: [ShopItem]
}

// MARK: - API 정의

enum ShopAPI {
    case getAllItems
}

extension ShopAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }

    var path: String {
        switch self {
        case .getAllItems:
            return "/shop/all"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")",
            "Content-Type": "application/json"
        ]
    }
}

// MARK: - 에러 정의

enum ShopAPIError: Error {
    case emptyResponse
    case decodingError
}

// MARK: - 서비스

final class ShopService {
    static let shared = ShopService()
    private let provider = MoyaProvider<ShopAPI>()

    func fetchAllItems() -> Single<[RankItemGroup]> {
        return provider.rx.request(.getAllItems)
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Single<[RankItemGroup]> in
                return self.parseRankItemGroups(from: response.data)
            }
    }

    private func parseRankItemGroups(from data: Data) -> Single<[RankItemGroup]> {
        if data.isEmpty {
            print("🔴 [ShopService] Empty response data")
            return Single.error(ShopAPIError.emptyResponse)
        }

        do {
            let groups = try JSONDecoder().decode([RankItemGroup].self, from: data)
            print("🟢 [ShopService] Successfully decoded \(groups.count) rank groups")
            return Single.just(groups)
        } catch {
            print("🔴 [ShopService] Decoding error: \(error)")
            return Single.error(ShopAPIError.decodingError)
        }
    }
}
