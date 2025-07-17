import Moya
import Foundation
import RxMoya
import UIKit
import RxSwift
import RxCocoa

enum ShopAPI {
    case getAllItems
    case buy(userId: Int, itemId: Int)
    case sell(userItemId: Int)
}

extension ShopAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://172.20.10.2:8080")!
    }

    var path: String {
        switch self {
        case .getAllItems:
            return "/item/all"
        case .buy:
            return "/item/buy"
        case .sell:
            return "/item/sell"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAllItems:
            return .get
        case .buy:
            return .post
        case .sell:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getAllItems:
            return .requestPlain

        case let .buy(userId, itemId):
            let body: [String: Any] = [
                "userId": userId,
                "itemId": itemId
            ]
            return .requestParameters(parameters: body, encoding: JSONEncoding.default)

        case let .sell(userItemId):
            let params: [String: Any] = [
                "userItemId": userItemId
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
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

final class ShopService {
    static let shared = ShopService()
    private let provider = MoyaProvider<ShopAPI>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])

    
    
    func sellItem(userItemId: Int) -> Completable {
         print("🟡 [ShopService] sellItem(userItemId: \(userItemId))")
         return provider.rx.request(.sell(userItemId: userItemId))
             .filterSuccessfulStatusCodes()
             .do(onSuccess: { _ in
                 print("🟢 [ShopService] 판매 성공 userItemId: \(userItemId)")
             }, onError: { error in
                 print("🔴 [ShopService] 판매 실패: \(error)")
             })
             .asCompletable()
     }
    
    
    func buyItem(userId: Int, itemId: Int) -> Single<Int> {
            print("🟡 [ShopService] buyItem(userId: \(userId), itemId: \(itemId))")
            return provider.rx.request(.buy(userId: userId, itemId: itemId))
                .filterSuccessfulStatusCodes()
                .map { response in
                    if let json = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                       let userItemId = json["userItemId"] as? Int {
                        print("🟢 [ShopService] 구매 성공 userItemId: \(userItemId)")
                        return userItemId
                    } else {
                        print("🔴 [ShopService] 구매 응답 파싱 실패")
                        throw ShopAPIError.decodingError
                    }
                }
        }
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
