struct Story: Identifiable, Codable {
    let id: String
    let userId: String
    let imageUrl: String
    let createdAt: String
    let finishTime: String
    var username: String? // Add this field
    var isCurrentUser: Bool? = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case imageUrl
        case createdAt
        case finishTime
        case username // Add this case
    }
}
