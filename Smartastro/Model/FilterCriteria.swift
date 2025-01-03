enum FilterCriteria {
    case allUsers
    case zodiacSameSign // Fetch users with the same zodiac sign
    case zodiacCompatibility // Fetch users with compatible zodiac signs
    case ageMatch // Fetch users with the same date of birth
    case genderMatch 
}
