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

    func saveSession(userId: String, accessToken: String, username: String, password: String, email: String, dateOfBirth: Date?, matches: [String]) {
        let newSession = Session(context: context)
        newSession.id = UUID()
        newSession.userId = userId
        newSession.accessToken = accessToken
        newSession.username = username
        newSession.password = password
        newSession.email = email

        // Decode dateOfBirth from token if not provided
        if let dateOfBirth = dateOfBirth {
            newSession.dateOfBirth = dateOfBirth
        } else if let decodedDOB = decodeDateOfBirthFromToken(token: accessToken) {
            newSession.dateOfBirth = decodedDOB
        } else if let dateOfBirth = dateOfBirth {
            newSession.dateOfBirth = dateOfBirth
        } else {
            print("[SessionManager] No valid dateOfBirth found; defaulting to current date.")
            newSession.dateOfBirth = Date()
        }
        
        if let decodedMatches = decodeMatchesFromToken(token: accessToken) {
                if let matchesData = try? JSONEncoder().encode(decodedMatches),
                   let matchesString = String(data: matchesData, encoding: .utf8) {
                    newSession.matches = matchesString // Save matches as a JSON string
                } else {
                    newSession.matches = "[]" // Fallback to an empty array string
                }
            } else {
                newSession.matches = "[]" // Fallback to an empty array string
            }
        

        newSession.createdAt = Date()

        do {
            try context.save()
            print("[SessionManager] Session saved successfully!")
            print("- User ID: \(userId)")
            print("- Username: \(username)")
            print("- Email: \(email)")
            print("- Password: \(password)")
            print("- Access Token: \(accessToken)")
            print("- Date of Birth: \(newSession.dateOfBirth ?? Date())")
        } catch {
            print("[SessionManager] Failed to save session: \(error.localizedDescription)")
        }
    }
    private func decodeDateOfBirthFromToken(token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let dobString = json["dateOfBirth"] as? String else {
            print("[SessionManager] Failed to decode dateOfBirth from token.")
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        if let dob = dateFormatter.date(from: dobString) {
            return dob
        } else {
            print("[SessionManager] Invalid dateOfBirth format in token: \(dobString)")
            return nil
        }
    }
    func debugTokenPayload(token: String) {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("[SessionManager] Invalid token format.")
            return
        }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("[SessionManager] Failed to decode token payload.")
            return
        }

        print("[SessionManager] Token Payload: \(json)")
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
    
    func decodeMatchesFromToken(token: String) -> [String]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("[SessionManager] Invalid token format.")
            return nil
        }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let matches = json["matches"] as? [String] else {
            print("[SessionManager] Failed to decode matches from token.")
            return nil
        }

        return matches
    }

    
}
