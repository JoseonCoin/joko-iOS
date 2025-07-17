import Foundation



struct EraChangeResponse: Decodable {
    let era: String
    let eventName: String
    let eventYear: Int
    let eventDescription: String
    let multiplier: Double
}
