import Foundation

func decodeJWT(_ token: String) -> [String: Any]? {
    let segments = token.components(separatedBy: ".")
    guard segments.count >= 2 else { return nil }

    let payloadSegment = segments[1]
    var base64 = payloadSegment
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

    // Base64 padding 처리
    while base64.count % 4 != 0 {
        base64 += "="
    }

    guard let data = Data(base64Encoded: base64),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }

    return json
}
