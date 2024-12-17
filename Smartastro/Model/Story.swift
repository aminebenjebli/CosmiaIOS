import Foundation

struct Story: Identifiable, Codable {
    let id: UUID
    let name: String   // User's name or identifier
    var images: [String] // Array of image URLs
    var isCurrentUser: Bool = false
}
