import Foundation

struct ZodiacHelper {
    static func determineZodiacSign(from dateString: String) -> String {
        let zodiacSigns = [
            ("Capricorn", (start: "12-22", end: "01-19")),
            ("Aquarius", (start: "01-20", end: "02-18")),
            ("Pisces", (start: "02-19", end: "03-20")),
            ("Aries", (start: "03-21", end: "04-19")),
            ("Taurus", (start: "04-20", end: "05-20")),
            ("Gemini", (start: "05-21", end: "06-20")),
            ("Cancer", (start: "06-21", end: "07-22")),
            ("Leo", (start: "07-23", end: "08-22")),
            ("Virgo", (start: "08-23", end: "09-22")),
            ("Libra", (start: "09-23", end: "10-22")),
            ("Scorpio", (start: "10-23", end: "11-21")),
            ("Sagittarius", (start: "11-22", end: "12-21"))
        ]

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Log the input date string
        print("Received dateOfBirth: \(dateString)")

        guard let date = dateFormatter.date(from: dateString) else {
            print("Failed to parse date: \(dateString)")
            return "Unknown"
        }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        print("Parsed date: \(date) -> Month: \(month), Day: \(day)")

        for (sign, range) in zodiacSigns {
            let start = range.start.split(separator: "-").map { Int($0)! }
            let end = range.end.split(separator: "-").map { Int($0)! }

            if (month == start[0] && day >= start[1]) ||
               (month == end[0] && day <= end[1]) ||
               (start[0] < end[0] && month > start[0] && month < end[0]) {
                print("Determined zodiac sign: \(sign)")
                return sign
            }
        }

        print("No zodiac sign matched for date: \(date)")
        return "Unknown"
    }
}
