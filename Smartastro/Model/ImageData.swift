import Foundation

struct ImageData: Codable {
    var id: String  // This will map to the _id field in the response
    var email: String
    var image: String // URL of the image

    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Map _id field to id property
        case email
        case image
    }
}
