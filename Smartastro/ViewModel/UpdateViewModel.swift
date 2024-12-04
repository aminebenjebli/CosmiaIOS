import Combine
import SwiftUI

class UpdateViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isUpdating: Bool = false
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let sessionManager = SessionManager.shared
    private var userId: String

    init(userId: String) {
        self.userId = userId
        print("[UpdateViewModel] Initialized with userId: \(userId)")
        loadUserDataFromSession()
    }

    // MARK: - Load User Data from Session
    private func loadUserDataFromSession() {
        guard let session = sessionManager.getActiveSession() else {
            handleError("No active session found.")
            return
        }

        self.userId = session.userId ?? ""
        self.username = session.username ?? ""
        self.email = session.email ?? ""
        self.dateOfBirth = session.dateOfBirth ?? Date()
        print("[UpdateViewModel] Loaded data from session: \(username), \(email), DOB: \(dateOfBirth)")
    }

    // MARK: - Validate Fields
    private func validateFields() -> Bool {
        guard !username.isEmpty else {
            handleError("Username cannot be empty.")
            return false
        }
        guard !email.isEmpty, isValidEmail(email) else {
            handleError("Please provide a valid email address.")
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "(?:[A-Za-z0-9]+(?:[.-_][A-Za-z0-9]+)*@[A-Za-z0-9.-]+(?:\\.[A-Za-z]{2,})+)"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // MARK: - Update User Profile
    func updateUser(completion: @escaping (Bool) -> Void) {
        guard validateFields() else {
            completion(false)
            return
        }

        isUpdating = true
        errorMessage = nil
        successMessage = nil

        print("[UpdateViewModel] Updating profile for userId: \(userId)")

        // Update Local Session First
        guard let session = sessionManager.getActiveSession() else {
            handleError("Failed to update session. No active session found.")
            isUpdating = false
            completion(false)
            return
        }

        session.username = username
        session.email = email
        session.dateOfBirth = dateOfBirth
        sessionManager.saveSession(
            userId: userId,
            accessToken: session.accessToken ?? "",
            username: username,
            password: session.password ?? "",
            email: email,
            dateOfBirth: dateOfBirth
        )
        print("[UpdateViewModel] Session updated successfully.")

        // Send Update Request to Backend
        guard let url = URL(string: "http://localhost:3000/user/update") else {
            handleError("Invalid update URL.")
            isUpdating = false
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updateData: [String: Any] = [
            "id": userId,
            "username": username,
            "email": email,
            "dateOfBirth": ISO8601DateFormatter().string(from: dateOfBirth) // Ensure date format is compatible
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
            print("[UpdateViewModel] Request body: \(updateData)")
        } catch {
            handleError("Failed to encode update data.")
            isUpdating = false
            completion(false)
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                print("[UpdateViewModel] Response status code: \(response.statusCode)")

                if (200...299).contains(response.statusCode) {
                    return output.data
                } else {
                    throw URLError(.badServerResponse)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                self.isUpdating = false
                switch completionResult {
                case .failure(let error):
                    self.handleError("Update failed: \(error.localizedDescription)")
                    completion(false)
                case .finished:
                    print("[UpdateViewModel] Backend update completed.")
                }
            }, receiveValue: { _ in
                self.successMessage = "Profile updated successfully."
                print("[UpdateViewModel] Profile updated successfully.")

                // Update session after successful backend update
                self.updateSession()

                completion(true)
            })
            .store(in: &self.cancellables)
    }

    // MARK: - Update Local Session
    private func updateSession() {
        guard let session = sessionManager.getActiveSession() else {
            print("[UpdateViewModel] No active session found. Unable to update session.")
            return
        }

        sessionManager.saveSession(
            userId: userId,
            accessToken: session.accessToken ?? "",
            username: username,
            password: session.password ?? "",
            email: email,
            dateOfBirth: dateOfBirth
        )

        print("[UpdateViewModel] Session successfully updated after backend confirmation.")
    }

    // MARK: - Error Handling
    private func handleError(_ message: String) {
        errorMessage = message
        print("[UpdateViewModel] Error: \(message)")
    }
}
