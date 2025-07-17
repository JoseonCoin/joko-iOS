import Foundation
import RxSwift
import Moya
import RxMoya

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
            return "/item/all"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        if token.isEmpty {
            print("🚨 [ShopAPI] ⚠️ access_token is empty!")
        } else {
            print("✅ [ShopAPI] Using access_token: \(token)")
            headers["Authorization"] = "Bearer \(token)"
        }
        headers["Content-Type"] = "application/json"
        return headers
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
    private let provider = MoyaProvider<ShopAPI>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])

    func fetchAllItems() -> Single<[RankItemGroup]> {
        print("🟡 [ShopService] fetchAllItems() called")
        return provider.rx.request(.getAllItems)
            .do(onSubscribe: {
                print("📡 [ShopService] Sending request to \(ShopAPI.getAllItems.path)")
            })
            .map { response in
                print("🔵 [ShopService] Received response — statusCode: \(response.statusCode), dataLength: \(response.data.count)")
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("📄 [ShopService] Response body: \(responseString)")
                }
                return response
            }
            .do(onError: { error in
                print("🔴 [ShopService] Request failed with error: \(error)")
            })
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
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 [ShopService] Raw response body for debugging:\n\(responseString)")
            }
            return Single.error(ShopAPIError.decodingError)
        }
    }
}
