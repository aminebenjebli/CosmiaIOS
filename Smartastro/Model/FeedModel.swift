import Foundation

struct FeedModel: Identifiable, Codable {
    let id: String
    let email: String
    let zodiacSign: String
    let luckyNumber: Int
    let luckyColor: String
    let description: String
    let image: String
    let createdAt: Date
    let updatedAt: Date // Add this field

    enum CodingKeys: String, CodingKey {
        case id = "_id" // Map "_id" to "id"
        case email
        case zodiacSign
        case luckyNumber
        case luckyColor
        case description
        case image
        case createdAt
        case updatedAt // Ensure this matches the JSON key
    }
}
