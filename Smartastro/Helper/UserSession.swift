import Foundation
import Combine

class UserSession: ObservableObject {
    static let shared = UserSession()

    @Published var userId: String? {
        didSet {
            print("UserSession userId updated: \(userId ?? "nil")")
        }
    }
    @Published var accessToken: String? {
        didSet {
            print("UserSession accessToken updated: \(accessToken ?? "nil")")
        }
    }
    @Published var username: String? {
        didSet {
            print("UserSession username updated: \(username ?? "nil")")
        }
    }
    @Published var password: String? {
        didSet {
            print("UserSession password updated: \(password != nil ? "******" : "nil")")
        }
        
    }


    private init() {
            // Initialize userId from active session
            if let activeSession = SessionManager.shared.getActiveSession() {
                userId = activeSession.userId
                print("Active session found: \(userId ?? "nil")")
            } else {
                print("No active session found.")
            }
        }

    func clearSession() {
        userId = nil
        accessToken = nil
        username = nil
        password = nil
        print("UserSession cleared.")
    }
}
