import Foundation
import Combine
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var emailId: String = "" {
        didSet {
            emailEdited = true
            validateEmail()
        }
    }
    @Published var userName: String = ""
    @Published var password: String = "" {
        didSet {
            passwordEdited = true
            validatePassword()
        }
    }
    @Published var confirmPassword: String = "" {
        didSet {
            confirmPasswordEdited = true
            validateConfirmPassword()
        }
    }
    @Published var birthDate = Date()
    @Published var emailIsValid: Bool = true
    @Published var passwordIsValid: Bool = true
    @Published var confirmPasswordIsValid: Bool = true
    @Published var isSignUpButtonDisabled: Bool = true
    @Published var emailEdited: Bool = false
    @Published var passwordEdited: Bool = false
    @Published var confirmPasswordEdited: Bool = false
    @Published var showSuccessPopup: Bool = false
    @Published var errorMessage: String = ""

    @Binding var showSignup: Bool  // Control redirection to the Login page

    private var cancellables = Set<AnyCancellable>()

    init(showSignup: Binding<Bool>) {
        self._showSignup = showSignup
        Publishers.CombineLatest3($emailId, $password, $confirmPassword)
            .sink { [weak self] email, password, confirmPassword in
                self?.emailIsValid = self?.isValidEmail(email) ?? false
                self?.passwordIsValid = self?.isStrongPassword(password) ?? false
                self?.confirmPasswordIsValid = self?.isPasswordMatching(password, confirmPassword) ?? false
                self?.updateSignUpButtonState()
            }
            .store(in: &cancellables)
    }
    var birthDateFormatted: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: birthDate)
        }

    func signUpUser() {
        let dateFormatter = ISO8601DateFormatter()
                let birthDateString = dateFormatter.string(from: birthDate)

        let newUser = User(username: userName, email: emailId, password: password, dateOfBirth: birthDateString)
                guard let url = URL(string: "http://localhost:3000/user/signup") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(newUser)
        } catch {
            print("Failed to encode user: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    self?.showSuccessPopup = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.showSuccessPopup = false
                        self?.showSignup = false // Automatically redirect to login
                    }
                }

                self?.sendWelcomeEmail(to: self?.emailId ?? "")
            } else {
                print("Failed to sign up: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
            }
        }.resume()
    }

    func sendWelcomeEmail(to email: String) {
        let apiKey = "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"
        let url = URL(string: "https://api.brevo.com/v3/smtp/email")!

        let emailData: [String: Any] = [
            "sender": ["name": "SmartAstro Team", "email": "azizkaboudi123@gmail.com"],
            "to": [["email": email]],
            "subject": "✨ Welcome to SmartAstro!",
            "htmlContent": """
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        background-color: #f4f4f9;
                        margin: 0;
                        padding: 0;
                    }
                    .email-container {
                        background-color: #ffffff;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        max-width: 600px;
                        margin: 20px auto;
                        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                    }
                    .header {
                        background-color: #6c63ff;
                        color: white;
                        padding: 20px;
                        text-align: center;
                        border-top-left-radius: 8px;
                        border-top-right-radius: 8px;
                    }
                    .header h1 {
                        margin: 0;
                        font-size: 24px;
                    }
                    .content {
                        padding: 20px;
                        color: #333;
                    }
                    .content h2 {
                        color: #6c63ff;
                    }
                    .content p {
                        font-size: 16px;
                        line-height: 1.6;
                    }
                    .cta-button {
                        display: block;
                        text-align: center;
                        margin: 20px 0;
                    }
                    .cta-button a {
                        text-decoration: none;
                        padding: 10px 20px;
                        background-color: #6c63ff;
                        color: white;
                        border-radius: 5px;
                        font-weight: bold;
                    }
                    .footer {
                        background-color: #f4f4f9;
                        color: #aaa;
                        text-align: center;
                        padding: 10px;
                        font-size: 12px;
                        border-bottom-left-radius: 8px;
                        border-bottom-right-radius: 8px;
                    }
                </style>
            </head>
            <body>
                        <div class="email-container">
                            <div class="header">
                                <h1>Welcome to SmartAstro! 🌌</h1>
                            </div>
                            <div class="content">
                                <h2>Hello, \(userName)!</h2>
                                <p>We’re thrilled to have you on board. SmartAstro is your gateway to exploring the wonders of the universe and understanding your astrological journey.</p>
                                <p>Here’s what you can do next:</p>
                                <ul>
                                    <li>🌟 Explore detailed celestial insights.</li>
                                    <li>🪐 Get personalized astrological readings.</li>
                                    <li>🔭 Stay updated on upcoming cosmic events.</li>
                                </ul>
                                <p>If you have any questions or need assistance, feel free to contact our support team. We’re here to help!</p>
                                <div class="cta-button">
                                    <a href="https://smartastro.com" target="_blank">Visit SmartAstro</a>
                                </div>
                            </div>
                            <div class="footer">
                                <p>You’re receiving this email because you signed up for SmartAstro.</p>
                                <p>Need help? <a href="mailto:support@smartastro.com">Contact Support</a></p>
                            </div>
                        </div>
                    </body>
            </html>
            """
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
        } catch {
            print("Failed to encode email data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send email: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("Welcome email sent successfully to \(email).")
            } else {
                print("Failed to send email: \(String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error")")
            }
        }.resume()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[A-Za-z0-9]+(?:[.-_][A-Za-z0-9]+)*@[A-Za-z0-9.-]+(?:\\.[A-Za-z]{2,})+)"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    private func isStrongPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }

    private func isPasswordMatching(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }

    private func validateEmail() {
        emailIsValid = isValidEmail(emailId)
    }

    private func validatePassword() {
        passwordIsValid = isStrongPassword(password)
    }

    private func validateConfirmPassword() {
        confirmPasswordIsValid = isPasswordMatching(password, confirmPassword)
    }

    private func updateSignUpButtonState() {
        isSignUpButtonDisabled = emailId.isEmpty || password.isEmpty || confirmPassword.isEmpty || userName.isEmpty || !emailIsValid || !passwordIsValid || !confirmPasswordIsValid
    }
}
