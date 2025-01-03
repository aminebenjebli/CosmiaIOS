import Foundation
import Combine

class UpdatePasswordViewModel: ObservableObject {
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isUpdating: Bool = false
    @Published var passwordsDoNotMatchMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private let sessionManager = SessionManager.shared
    private var userId: String
    private var savedPassword: String

    init() {
        guard let session = sessionManager.getActiveSession() else {
            fatalError("[UpdatePasswordViewModel] No active session found!")
        }
        self.userId = session.userId ?? ""
        self.savedPassword = session.password ?? "" // Load the plain password from the session
        print("[UpdatePasswordViewModel] Initialized with userId: \(userId)")
    }

    var isFormValid: Bool {
        isValidPassword(currentPassword) &&
        isValidPassword(newPassword) &&
        newPassword == confirmNewPassword
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    private func checkSessionValidity() -> Bool {
        guard sessionManager.getActiveSession() != nil else {
            DispatchQueue.main.async {
                self.handleError("Session has expired. Please log in again.")
            }
            return false
        }
        return true
    }

    func updatePassword() {
        guard checkSessionValidity() else { return }

        guard isFormValid else {
            DispatchQueue.main.async {
                self.passwordsDoNotMatchMessage = self.newPassword != self.confirmNewPassword ? "Passwords do not match." : nil
                self.errorMessage = "Please ensure all fields are valid and meet criteria."
            }
            print("[UpdatePasswordViewModel] Validation failed.")
            return
        }

        guard currentPassword == savedPassword else {
            DispatchQueue.main.async {
                self.handleError("Current password is incorrect.")
            }
            return
        }

        guard currentPassword != newPassword else {
            DispatchQueue.main.async {
                self.handleError("New password cannot be the same as the current password.")
            }
            return
        }

        DispatchQueue.main.async {
            self.isUpdating = true
            self.errorMessage = nil
            self.successMessage = nil
            self.passwordsDoNotMatchMessage = nil
        }

        guard let url = URL(string: "http://localhost:3000/user/update-password") else {
            DispatchQueue.main.async {
                self.handleError("Invalid update URL.")
                self.isUpdating = false
            }
            return
        }

        print("[UpdatePasswordViewModel] Sending update password request to: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updateData: [String: Any] = [
            "id": userId,
            "password": newPassword
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
            print("[UpdatePasswordViewModel] Request body: \(updateData)")
        } catch {
            DispatchQueue.main.async {
                self.handleError("Failed to encode update data.")
                self.isUpdating = false
            }
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                print("[UpdatePasswordViewModel] Response status code: \(response.statusCode)")

                if (200...299).contains(response.statusCode) {
                    // If response body is empty or not expected, bypass decoding
                    return Data()
                } else {
                    let errorResponse = String(data: output.data, encoding: .utf8) ?? "Unknown error"
                    print("[UpdatePasswordViewModel] Server error response: \(errorResponse)")
                    throw URLError(.badServerResponse)
                }
            }
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError("Update failed: \(error.localizedDescription)")
                }
                self?.isUpdating = false
            }, receiveValue: { [weak self] _ in
                self?.successMessage = "Password updated successfully."
                print("[UpdatePasswordViewModel] Password updated successfully.")

                // Update the session with the new plain password and matches
                if let session = self?.sessionManager.getActiveSession(),
                   let newPassword = self?.newPassword {
                    let matches = SessionManager.shared.decodeMatchesFromToken(token: session.accessToken ?? "") ?? []
                    self?.sessionManager.saveSession(
                        userId: session.userId ?? "",
                        accessToken: session.accessToken ?? "",
                        username: session.username ?? "",
                        password: newPassword, // Save the plain password
                        email: session.email ?? "",
                        dateOfBirth: session.dateOfBirth ?? Date(),
                        matches: matches,
                        gender: session.gender ?? "Select Gender"
                    )
                    print("[UpdatePasswordViewModel] Session updated with new password and matches.")
                } else {
                    self?.handleError("Failed to update session. Missing data.")
                }

                // Clear sensitive fields after success
                self?.clearPasswordFields()
            })
            .store(in: &cancellables)
    }


    private func clearPasswordFields() {
        DispatchQueue.main.async {
            self.currentPassword = ""
            self.newPassword = ""
            self.confirmNewPassword = ""
            print("[UpdatePasswordViewModel] Password fields cleared.")
        }
    }

    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            print("[UpdatePasswordViewModel] Error: \(message)")
        }
    }

    struct Response: Decodable {
        let success: Bool
        let message: String
    }
}
