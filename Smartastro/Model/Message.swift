import Foundation

struct Message: Codable, Identifiable, Equatable {
    let id: String
    let roomId: String
    let senderId: String?
    let receiverId: String?
    let content: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case roomId
        case senderId
        case receiverId
        case content = "message"
        case createdAt = "timestamp"
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.roomId == rhs.roomId &&
               lhs.senderId == rhs.senderId &&
               lhs.receiverId == rhs.receiverId &&
               lhs.content == rhs.content &&
               lhs.createdAt == rhs.createdAt
    }
}
