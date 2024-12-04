

import Foundation
struct ZodiacCompatibility {
    static let compatibility: [String: [String]] = [
        "Aries": ["Leo", "Sagittarius", "Gemini", "Aquarius"],
        "Taurus": ["Scorpio", "Virgo", "Capricorn", "Pisces"],
        "Gemini": ["Libra", "Aquarius", "Aries", "Leo"],
        "Cancer": ["Scorpio", "Pisces", "Taurus", "Virgo"],
        "Leo": ["Aries", "Sagittarius", "Gemini", "Libra"],
        "Virgo": ["Taurus", "Capricorn", "Cancer", "Scorpio"],
        "Libra": ["Gemini", "Aquarius", "Leo", "Sagittarius"],
        "Scorpio": ["Cancer", "Pisces", "Virgo", "Capricorn"],
        "Sagittarius": ["Aries", "Leo", "Libra", "Aquarius"],
        "Capricorn": ["Taurus", "Virgo", "Scorpio", "Pisces"],
        "Aquarius": ["Gemini", "Libra", "Aries", "Sagittarius"],
        "Pisces": ["Cancer", "Scorpio", "Taurus", "Capricorn"]
    ]
}
