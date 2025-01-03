
import Foundation

struct User: Codable {
    var id: String?
    var username: String
    var email: String
    var password: String
    var dateOfBirth: String
    var image: String?
    var albumImages: [String]?
    var gender: String?
 // Array of matched user IDs
    //var likedUser: String
    // Computed property, not part of Codable
    var zodiacSign: String {
        ZodiacHelper.determineZodiacSign(from: dateOfBirth)
    }

    // Map backend keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id = "_id" // Map `_id` to `id`
        case username
        case email
        case password
        case dateOfBirth
        case image
        case gender
    }
}

