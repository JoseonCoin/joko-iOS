import Foundation

func decodeJWT(_ jwt: String) -> [String: Any]? {
    let segments = jwt.components(separatedBy: ".")
    guard segments.count == 3 else {
        print("🔴 JWT 포맷 오류")
        return nil
    }
    
    let payloadSegment = segments[1]
    
    // Base64 디코딩
    var base64 = payloadSegment
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    // Base64 padding 추가
    let paddedLength = base64.count + (4 - (base64.count % 4)) % 4
    base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
    
    guard let payloadData = Data(base64Encoded: base64) else {
        print("🔴 Base64 디코딩 실패")
        return nil
    }
    
    do {
        let json = try JSONSerialization.jsonObject(with: payloadData, options: [])
        return json as? [String: Any]
    } catch {
        print("🔴 JSON 파싱 실패: \(error)")
        return nil
    }
}
