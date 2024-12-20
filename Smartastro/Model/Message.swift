import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String // Corresponds to _id in MongoDB
    let senderId: String
    let receiverId: String
    let content: String
    let createdAt: String
    let read: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderId
        case receiverId
        case content
        case createdAt
        case read
    }
}
