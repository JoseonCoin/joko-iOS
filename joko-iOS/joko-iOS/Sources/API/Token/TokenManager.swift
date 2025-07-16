import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let userIdKey = "user_id"
    
    private init() {}
    
    
    func saveTokens(accessToken: String, refreshToken: String? = nil) {
        userDefaults.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            userDefaults.set(refreshToken, forKey: refreshTokenKey)
        }
        
        
        if let payload = decodeJWT(accessToken),
           let userId = payload["userId"] as? Int {
            print("✅ 디코딩된 userId: \(userId)")
            userDefaults.set(userId, forKey: userIdKey)
        } else {
            print("❌ userId 디코딩 실패")
        }
        
        userDefaults.synchronize()
        print("토큰이 저장되었습니다.")
    }
    
    // MARK: - Token Retrieval
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return userDefaults.string(forKey: refreshTokenKey)
    }
    
    func getUserId() -> Int? {
        let userId = userDefaults.integer(forKey: userIdKey)
        return userId > 0 ? userId : nil
    }
    
    // MARK: - Token Validation
    func hasValidToken() -> Bool {
        guard let token = getAccessToken(), !token.isEmpty else {
            return false
        }
        
        // JWT 토큰 만료 체크 (선택사항)
        if isTokenExpired(token) {
            return false
        }
        
        return true
    }
    
    // MARK: - Token Cleanup
    func clearTokens() {
        userDefaults.removeObject(forKey: accessTokenKey)
        userDefaults.removeObject(forKey: refreshTokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.synchronize()
        print("토큰이 삭제되었습니다.")
    }
    
    // MARK: - JWT Token Decoding
    func decodeJWT(_ token: String) -> [String: Any]? {
        let components = token.components(separatedBy: ".")
        guard components.count == 3 else { return nil }
        
        let payloadComponent = components[1]
        var payload = payloadComponent
        
        // Base64 패딩 추가
        let remainder = payload.count % 4
        if remainder > 0 {
            payload = payload.padding(toLength: payload.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    
    // MARK: - JWT Token Expiration Check (선택사항)
    private func isTokenExpired(_ token: String) -> Bool {
        guard let payload = decodeJWT(token),
              let exp = payload["exp"] as? TimeInterval else {
            return true
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate < Date()
    }
}
