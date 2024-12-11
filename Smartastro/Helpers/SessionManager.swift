import CoreData
import Foundation
import CryptoKit

class SessionManager {
    static let shared = SessionManager()
    private let context: NSManagedObjectContext
    private let sessionExpiryInterval: TimeInterval = 3600

    private init() {
        self.context = PersistenceController.shared.container.viewContext
    }

    func saveSession(userId: String, accessToken: String, username: String, password: String, email: String, dateOfBirth: Date) {
        let newSession = Session(context: context)
        newSession.id = UUID()
        newSession.userId = userId
        newSession.accessToken = accessToken
        newSession.username = username
        newSession.password = password // Store the plain password
        newSession.email = email
        newSession.dateOfBirth = dateOfBirth
        newSession.createdAt = Date() // Current timestamp

        do {
            try context.save()
            print("Session saved successfully!")
            print("Saved session details:")
            print("- User ID: \(userId)")
            print("- Username: \(username)")
            print("- Email: \(email)")
            print("- Password: \(password)") // Added for debug purposes
            print("- Access Token: \(accessToken)")
            print("- date of birth: \(dateOfBirth)")
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }
    // MARK: - Retrieve Active Session
    func getActiveSession() -> Session? {
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()

        do {
            let sessions = try context.fetch(fetchRequest)
            guard let session = sessions.sorted(by: { $0.createdAt ?? Date.distantPast > $1.createdAt ?? Date.distantPast }).first else {
                print("No active session found.")
                return nil
            }

            // Validate session expiry
            if let createdAt = session.createdAt,
               Date().timeIntervalSince(createdAt) <= sessionExpiryInterval {
                return session
            } else {
                print("Session expired. Deleting old session.")
                deleteSession(session)
                return nil
            }
        } catch {
            print("Failed to fetch session: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Delete Session
    func deleteSession(_ session: Session) {
        context.delete(session)
        do {
            try context.save()
            print("Session deleted successfully!")
        } catch {
            print("Failed to delete session: \(error.localizedDescription)")
        }
    }

    // MARK: - Clear All Sessions
    func clearAllSessions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            print("All sessions cleared.")
        } catch {
            print("Failed to clear sessions: \(error.localizedDescription)")
        }
    }

    // MARK: - Password Hashing
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    func updateSession(session: Session, username: String, email: String, dateOfBirth: Date) {
            session.username = username
            session.email = email
            session.dateOfBirth = dateOfBirth
            session.createdAt = Date() 

            do {
                try context.save()
                print("[SessionManager] Session updated successfully!")
                print("- Username: \(username)")
                print("- Email: \(email)")
                print("- Date of Birth: \(dateOfBirth)")
            } catch {
                print("[SessionManager] Failed to update session: \(error.localizedDescription)")
            }
        }
    
}
