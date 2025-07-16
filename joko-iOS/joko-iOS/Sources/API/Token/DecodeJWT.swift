import Foundation

// JWT 디코딩 전역 함수
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
