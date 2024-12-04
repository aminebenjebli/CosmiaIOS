
import Foundation

struct User: Codable {
    var username: String
    var email: String
    var password: String
    var dateOfBirth: String
    var image: String?
    var zodiacSign: String {
           ZodiacHelper.determineZodiacSign(from: dateOfBirth)
       }
}
