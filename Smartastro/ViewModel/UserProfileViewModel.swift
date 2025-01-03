import Foundation
import Combine
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: Date = Date() // Use Date for dateOfBirth
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isUpdating: Bool = false
    @Published var isLoading: Bool = false
    @Published var shouldRedirectToLogin = false // Navigation trigger// API backend for album
    
    private let apiUrl = "http://localhost:3000" // Base API URL

    private var cancellables = Set<AnyCancellable>()
    let userId: String
    private let sessionManager = SessionManager.shared

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()


    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var isFormValid: Bool {
        !username.isEmpty && isEmailValid && !password.isEmpty && password == confirmPassword
    }

    init(userId: String) {
        self.userId = userId
        print("[UserProfileViewModel] Initialized with userId: \(userId)")
        loadInitialDataFromSession()
    }

    func loadInitialDataFromSession() {
        guard let session = sessionManager.getActiveSession() else {
            handleError("No active session found.")
            return
        }

        username = session.username ?? ""
        email = session.email ?? ""
        dateOfBirth = session.dateOfBirth ?? Date()
        print("Loaded session data: username=\(username), email=\(email), dateOfBirth=\(dateOfBirth)")
    }

    func loadInitialDataFromBackend() {
        print("Fetching user data for userId: \(userId)")
        guard let url = URL(string: "http://localhost:3000/user/\(userId)") else {
            handleError("Invalid user data URL.")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.handleError("Failed to fetch user data: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data else {
                    self?.handleError("Failed to parse user data.")
                    return
                }

                do {
                    if let userResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let username = userResponse["username"] as? String,
                       let email = userResponse["email"] as? String,
                       let dobString = userResponse["dateOfBirth"] as? String {
                        self?.username = username
                        self?.email = email
                        self?.dateOfBirth = self?.dateFormatter.date(from: dobString) ?? Date() // Parse the date
                        print("Fetched user: \(username), \(email), dateOfBirth=\(self?.dateOfBirth ?? Date())")
                    } else {
                        self?.handleError("Failed to decode user data.")
                    }
                } catch {
                    self?.handleError("Error decoding user data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
                                //function update Profile //

    func updateProfile() {
        guard isFormValid else {
            handleError("Please ensure all fields are valid and passwords match.")
            return
        }

        isUpdating = true
        errorMessage = nil
        successMessage = nil

        print("Updating profile for userId: \(userId)")

        guard let url = URL(string: "http://localhost:3000/user/\(userId)") else {
            handleError("Invalid update URL.")
            isUpdating = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updateData: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "dateOfBirth": dateFormatter.string(from: dateOfBirth), // Convert Date to String
            "gender": sessionManager.getActiveSession()?.gender ?? "Select gender"

        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
            print("[UserProfileViewModel] Request body: \(updateData)")
        } catch {
            handleError("Failed to encode update data.")
            isUpdating = false
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isUpdating = false
                if let error = error {
                    self?.handleError("Update failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self?.handleError("Failed to update user profile.")
                    return
                }
                let matches = self?.sessionManager.decodeMatchesFromToken(token: self?.sessionManager.getActiveSession()?.accessToken ?? "") ?? []

                self?.sessionManager.saveSession(
                    userId: self?.userId ?? "",
                    accessToken: self?.sessionManager.getActiveSession()?.accessToken ?? "",
                    username: self?.username ?? "",
                    password: self?.password ?? "",
                    email: self?.email ?? "",
                    dateOfBirth: self?.dateOfBirth ?? Date(),
                    matches : matches,
                    gender: self?.sessionManager.getActiveSession()?.gender ?? ""
                )

                self?.successMessage = "Profile updated successfully."
                print("[UserProfileViewModel] Profile updated for userId: \(self?.userId ?? "")")
            }
        }.resume()
    }

    private func handleError(_ message: String) {
        errorMessage = message
        print("[UserProfileViewModel] Error: \(message)")
    }
    
    
    
    func fetchAllUsersWithAlbums() {
        guard let currentUserId = SessionManager.shared.getActiveSession()?.userId else {
            errorMessage = "No active user session"
            return
        }
        
        guard let url = URL(string: "\(apiUrl)/user/get") else {
            errorMessage = "Invalid URL for fetching users"
            return
        }
        
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [User].self, decoder: JSONDecoder())
            .flatMap { users -> AnyPublisher<[User], Never> in
                // Exclude the current user
                let filteredUsers = users.filter { $0.id != currentUserId }
                // Fetch album images for each filtered user
                let fetchAlbums = filteredUsers.map { self.fetchAlbums(for: $0) }
                return Publishers.MergeMany(fetchAlbums)
                    .collect()
                    .map { usersWithAlbums in
                        // Keep only users who have at least one album image
                        usersWithAlbums.filter { $0.albumImages?.isEmpty == false }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] usersWithAlbums in
                self?.users = usersWithAlbums
            })
            .store(in: &cancellables)
    }


        
        private func fetchAlbums(for user: User) -> AnyPublisher<User, Never> {
            guard let url = URL(string: "\(apiUrl)/album/\(user.email)") else {
                return Just(user).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: [Album].self, decoder: JSONDecoder())
                .map { albums in
                    var updatedUser = user
                    updatedUser.albumImages = albums.map { $0.image } // Extract album image URLs
                    return updatedUser
                }
                .replaceError(with: user) // If an error occurs, return the user without album images
                .eraseToAnyPublisher()
        }
    func determineZodiacImage(from date: Date) -> String {
        let zodiacImages = [
            ("capricorn", (start: "12-22", end: "01-19")),
            ("aquarius", (start: "01-20", end: "02-18")),
            ("pisces", (start: "02-19", end: "03-20")),
            ("aries", (start: "03-21", end: "04-19")),
            ("taurus", (start: "04-20", end: "05-20")),
            ("gemini", (start: "05-21", end: "06-20")),
            ("cancer", (start: "06-21", end: "07-22")),
            ("leo", (start: "07-23", end: "08-22")),
            ("virgo", (start: "08-23", end: "09-22")),
            ("libra", (start: "09-23", end: "10-22")),
            ("scorpio", (start: "10-23", end: "11-21")),
            ("sagittarius", (start: "11-22", end: "12-21"))
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"

        let dateString = formatter.string(from: date)
        let dateComponents = dateString.split(separator: "-").map { Int($0)! }

        for (image, range) in zodiacImages {
            let startComponents = range.start.split(separator: "-").map { Int($0)! }
            let endComponents = range.end.split(separator: "-").map { Int($0)! }

            if (dateComponents[0] == startComponents[0] && dateComponents[1] >= startComponents[1]) ||
                (dateComponents[0] == endComponents[0] && dateComponents[1] <= endComponents[1]) ||
                (startComponents[0] < endComponents[0] && (dateComponents[0] > startComponents[0] && dateComponents[0] < endComponents[0])) {
                return image
            }
        }

        return "Taurus"
    }
    
    func likeUser(userId: String, likedUserId: String, completion: @escaping (Result<User?, Error>) -> Void) {
        print("[UserProfileViewModel] User \(userId) likes \(likedUserId)")
        guard let url = URL(string: "http://localhost:3000/user/like") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["userId": userId, "likedUserId": likedUserId]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    let errorMessage = "Unexpected response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
                    return
                }

                // Handle the response for a match or a like
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from server: \(responseString)")
                    if responseString.contains("It’s a match!") {
                        self.fetchMatchedUser(likedUserId: likedUserId, completion: completion)
                    } else {
                        completion(.success(nil)) // Like without match
                    }
                } else {
                    completion(.success(nil)) // Like without match
                }
            }
        }.resume()
    }
    private func fetchMatchedUser(likedUserId: String, completion: @escaping (Result<User?, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/user/\(likedUserId)") else {
            print("Invalid URL for fetching matched user")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                    return
                }

                do {
                    let matchedUser = try JSONDecoder().decode(User.self, from: data)
                    print("Fetched matched user: \(matchedUser.username)")
                    completion(.success(matchedUser))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func filterUsers(by criteria: FilterCriteria) {
        // Get the current user's date of birth as a string
        let currentUserDateOfBirthString = dateFormatter.string(from: dateOfBirth)

        switch criteria {
        case .zodiacSameSign:
            // Get the current user's zodiac sign
            let currentUserZodiac = ZodiacHelper.determineZodiacSign(from: currentUserDateOfBirthString)
            print("Filtering by same zodiac sign: \(currentUserZodiac)")

            // Filter users with the same zodiac sign
            users = users.filter { user in
                let userZodiac = ZodiacHelper.determineZodiacSign(from: user.dateOfBirth)
                return userZodiac == currentUserZodiac
            }

        case .zodiacCompatibility:
            // Get the current user's zodiac sign
            let currentUserZodiac = ZodiacHelper.determineZodiacSign(from: currentUserDateOfBirthString)
            let compatibleSigns = getCompatibleSigns(for: currentUserZodiac)
            print("Filtering by compatible zodiac signs for: \(currentUserZodiac). Compatible: \(compatibleSigns)")

            // Filter users with compatible zodiac signs
            users = users.filter { user in
                let userZodiac = ZodiacHelper.determineZodiacSign(from: user.dateOfBirth)
                return compatibleSigns.contains(userZodiac)
            }

        case .ageMatch:
            // Fetch users with the same date of birth
            users = users.filter { user in
                user.dateOfBirth == currentUserDateOfBirthString
            }

        case .allUsers:
            // Reset the filter and fetch all users
            fetchAllUsersWithAlbums()
        }
    }



    private func getCompatibleSigns(for sign: String) -> [String] {
            ZodiacCompatibility.compatibility[sign] ?? []
        }
    

    func fetchMatches() {
        // Ensure there's an active session and an access token
        guard let currentSession = SessionManager.shared.getActiveSession(),
              let accessToken = currentSession.accessToken,
              let matchesFromToken = SessionManager.shared.decodeMatchesFromToken(token: accessToken) else {
            errorMessage = "No active session or matches found"
            return
        }

        isLoading = true

        // Fetch each matched user's details using `fetchMatchedUser`
        let matchedUsersDispatchGroup = DispatchGroup()
        var matchedUsers: [User] = []

        for matchedUserId in matchesFromToken {
            matchedUsersDispatchGroup.enter()
            fetchMatchedUser(likedUserId: matchedUserId) { result in
                switch result {
                case .success(let matchedUser):
                    if let user = matchedUser {
                        matchedUsers.append(user)
                    }
                case .failure(let error):
                    print("Failed to fetch matched user: \(error.localizedDescription)")
                }
                matchedUsersDispatchGroup.leave()
            }
        }

        // Wait for all matched user fetches to complete
        matchedUsersDispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.users = matchedUsers
            print("Fetched all matched users: \(matchedUsers.map { $0.username })")
        }
    }
}
