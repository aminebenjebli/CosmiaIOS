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
    @Published var shouldRedirectToLogin = false // Navigation trigger

    private var cancellables = Set<AnyCancellable>()
    let userId: String
    private let sessionManager = SessionManager.shared

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
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
            "dateOfBirth": dateFormatter.string(from: dateOfBirth) // Convert Date to String
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

                self?.sessionManager.saveSession(
                    userId: self?.userId ?? "",
                    accessToken: self?.sessionManager.getActiveSession()?.accessToken ?? "",
                    username: self?.username ?? "",
                    password: self?.password ?? "",
                    email: self?.email ?? "",
                    dateOfBirth: self?.dateOfBirth ?? Date()
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
    
    
    
    func fetchAllUsers() {
           guard let url = URL(string: "http://localhost:3000/user/get") else {
               errorMessage = "Invalid URL for fetching users"
               return
           }

           isLoading = true
           URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               DispatchQueue.main.async {
                   self?.isLoading = false
                   if let error = error {
                       self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                       return
                   }

                   guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                         let data = data else {
                       self?.errorMessage = "Failed to parse user data"
                       return
                   }

                   do {
                       let usersResponse = try JSONDecoder().decode([User].self, from: data)
                       self?.users = usersResponse
                   } catch {
                       self?.errorMessage = "Error decoding user data: \(error.localizedDescription)"
                   }
               }
           }.resume()
       }

}
