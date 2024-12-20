import Foundation
import Combine

enum LoginStatus {
    case otpRequired
    case success
    case accountDoesNotExist
    case error
}

class LoginViewModel: ObservableObject {
    @Published var emailId: String = "" {
        didSet {
            emailEdited = true
            validateEmail()
        }
    }
    @Published var password: String = "" {
        didSet {
            passwordEdited = true
            validatePassword()
        }
    }
    @Published var emailIsValid: Bool = true
    @Published var passwordIsValid: Bool = true
    @Published var isLoginButtonDisabled: Bool = true
    @Published var emailEdited: Bool = false
    @Published var passwordEdited: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var userId: String = ""

    private var isLoginInProgress = false // Prevents multiple login requests
    private var cancellables = Set<AnyCancellable>()

    init() {
            Publishers.CombineLatest($emailId, $password)
                .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
                .sink { [weak self] email, password in
                    guard let self = self else { return }
                    self.emailIsValid = self.isValidEmail(email)
                    self.passwordIsValid = self.isStrongPassword(password)
                    self.updateLoginButtonState()
                }
                .store(in: &cancellables)
        }

    func loginUser(completion: @escaping (LoginStatus) -> Void) {
        guard !isLoginInProgress else {
            print("Login already in progress. Ignoring duplicate request.")
            return // Prevent duplicate requests
        }
        isLoginInProgress = true
        print("Starting login process...")

        guard let url = URL(string: "http://localhost:3000/user/login") else {
            print("Invalid URL. Ensure the URL is correct.")
            isLoginInProgress = false
            return
        }

        let loginPayload = ["email": emailId, "password": password]
        print("Login payload: \(loginPayload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginPayload)
            print("Request body set successfully.")
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            isLoginInProgress = false
            completion(.error)
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoginInProgress = false

                if let error = error {
                    print("Network error occurred: \(error.localizedDescription)")
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    self.showError = true
                    completion(.error)
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    print("Unexpected response or no data received.")
                    self.errorMessage = "Unexpected error occurred."
                    self.showError = true
                    completion(.error)
                    return
                }

                print("HTTP Response Status Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 404 {
                    print("Account does not exist.")
                    completion(.accountDoesNotExist)
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = jsonResponse["access_token"] as? String,
                       let user = jsonResponse["user"] as? [String: Any],
                       let userId = user["id"] as? String,
                       let username = user["username"] as? String,
                       let email = user["email"] as? String {

                        print("Login successful. Access token received.")

                        // Decode token to extract dateOfBirth
                        var decodedDateOfBirth: Date = Date() // Default to current date
                        if let tokenData = self.decodeJWT(token: token) {
                            print("Decoded Token Payload: \(tokenData)")
                            
                            if let dobString = tokenData["dateOfBirth"] as? String {
                                let dateFormatter = ISO8601DateFormatter()
                                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                if let dob = dateFormatter.date(from: dobString) {
                                    decodedDateOfBirth = dob
                                    print("Decoded dateOfBirth from token: \(dob)")
                                } else {
                                    print("Failed to parse dateOfBirth string: \(dobString)")
                                }
                            } else {
                                print("dateOfBirth not found in token payload.")
                            }
                        }

                        // Save session with the decoded or fallback dateOfBirth
                        SessionManager.shared.saveSession(
                            userId: userId,
                            accessToken: token,
                            username: username,
                            password: self.password,
                            email: email,
                            dateOfBirth: decodedDateOfBirth
                        )
                        print("SessionManager saved session for User ID: \(userId)")

                        // Update UserSession
                        UserSession.shared.userId = userId
                        UserSession.shared.accessToken = token
                        UserSession.shared.username = username
                        UserSession.shared.password = self.password

                        print("UserSession Updated: User ID: \(userId), Username: \(username), Access Token: \(token)")
                        completion(.success)
                    } else {
                        print("Unexpected server response. Login failed.")
                        self.errorMessage = "Login failed. Please try again."
                        self.showError = true
                        completion(.error)
                    }
                } catch {
                    print("Error decoding JSON response: \(error.localizedDescription)")
                    self.errorMessage = "Failed to parse server response."
                    self.showError = true
                    completion(.error)
                }
            }
        }.resume()
    }

    func decodeJWT(token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("JWT is malformed: Expected 3 segments but found \(segments.count).")
            return nil
        }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }

        return json
    }



    func sendOtp() {
        guard let url = URL(string: "http://localhost:3000/user/send-otp") else { return }

        let otpPayload = ["email": emailId]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: otpPayload)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to send OTP."
                self.showError = true
            }
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send OTP: \(error.localizedDescription)"
                    self.showError = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "OTP sent successfully."
                    self.showError = true
                }
            }
        }.resume()
    }
    
    func verifyOtp(otp: String, completion: @escaping (Bool) -> Void) {
        print("Starting OTP verification process...")
        print("OTP entered: \(otp)")
        
        guard let url = URL(string: "http://localhost:3000/user/verify-otp") else {
            print("Invalid URL for OTP verification.")
            return
        }

        let otpPayload = ["identifier": emailId, "otp": otp]
        print("OTP verification payload: \(otpPayload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: otpPayload)
            print("Successfully set OTP request body.")
        } catch {
            print("Error encoding OTP request body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode OTP data."
                self.showError = true
            }
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Network error during OTP verification: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    completion(false)
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    print("No response or data received for OTP verification.")
                    self.errorMessage = "Unexpected error during OTP verification."
                    self.showError = true
                    completion(false)
                    return
                }

                print("HTTP Response Status Code for OTP verification: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 201 {
                    print("OTP verification successful.")
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Server response after OTP verification: \(jsonResponse)")
                            self.errorMessage = "OTP verified successfully. Redirecting to home."
                            self.showError = false
                            completion(true) // Navigate to home
                        } else {
                            print("Failed to parse server response after OTP verification.")
                            self.errorMessage = "Failed to parse server response."
                            self.showError = true
                            completion(false)
                        }
                    } catch {
                        print("Error decoding JSON response for OTP verification: \(error.localizedDescription)")
                        self.errorMessage = "Failed to parse server response."
                        self.showError = true
                        completion(false)
                    }
                } else if httpResponse.statusCode == 400 {
                    print("Invalid or expired OTP.")
                    self.errorMessage = "Invalid or expired OTP."
                    self.showError = true
                    completion(false)
                } else {
                    print("Unexpected status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Unexpected error during OTP verification."
                    self.showError = true
                    completion(false)
                }
            }
        }.resume()
    }

    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/user/status") else {
            print("Invalid URL for account status check.")
            completion(false)
            return
        }

        let payload = ["identifier": emailId]
        print("Check account status payload: \(payload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            print("Request body set successfully for account status check.")
        } catch {
            print("Failed to encode request body.")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode request data."
                self.showError = true
            }
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    completion(false)
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    print("No response or data received for account status check.")
                    self.errorMessage = "Unexpected error occurred."
                    self.showError = true
                    completion(false)
                    return
                }

                print("HTTP Response Status Code for account status: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let status = jsonResponse["status"] as? String {
                            print("Account status: \(status)")
                            
                            if status.lowercased() == "verified" {
                                completion(true)
                            } else {
                                self.errorMessage = "Account not verified. Please verify your account."
                                self.showError = true
                                completion(false)
                            }
                        } else {
                            print("Failed to parse server response for account status.")
                            self.errorMessage = "Failed to parse server response."
                            self.showError = true
                            completion(false)
                        }
                    } catch {
                        print("Error decoding JSON response: \(error.localizedDescription)")
                        self.errorMessage = "Failed to parse server response."
                        self.showError = true
                        completion(false)
                    }
                } else {
                    print("Account status check failed with status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Account status check failed."
                    self.showError = true
                    completion(false)
                }
            }
        }.resume()
    }



    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[A-Za-z0-9]+(?:[.-_][A-Za-z0-9]+)*@[A-Za-z0-9.-]+(?:\\.[A-Za-z]{2,})+)"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func isStrongPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: password)
    }

    private func validateEmail() {
        emailIsValid = isValidEmail(emailId)
    }

    private func validatePassword() {
        passwordIsValid = isStrongPassword(password)
    }

    private func updateLoginButtonState() {
        isLoginButtonDisabled = emailId.isEmpty || password.isEmpty || !emailIsValid || !passwordIsValid
    }
    
    func forgetPassword(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/user/forget-password") else {
            print("Invalid URL for forget password.")
            return
        }

        let payload = ["email": emailId]
        print("Forget password payload: \(payload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to set request body.")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode request data."
                self.showError = true
            }
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    completion(false)
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    print("No response or data.")
                    self.errorMessage = "Unexpected error."
                    self.showError = true
                    completion(false)
                    return
                }

                print("HTTP Response Status Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("Password reset email sent successfully.")
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let message = jsonResponse["message"] as? String {
                            print("Backend response message: \(message)")
                            self.errorMessage = "Password reset email sent successfully."
                            self.showError = false
                            completion(true)
                        } else {
                            print("Failed to parse success response.")
                            self.errorMessage = "Failed to parse response."
                            self.showError = true
                            completion(false)
                        }
                    } catch {
                        print("Error decoding JSON response: \(error.localizedDescription)")
                        self.errorMessage = "Failed to parse server response."
                        self.showError = true
                        completion(false)
                    }
                } else {
                    print("Failed to send password reset email. Status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Failed to send password reset email."
                    self.showError = true
                    completion(false)
                }
            }
        }.resume()
    }

    
}
