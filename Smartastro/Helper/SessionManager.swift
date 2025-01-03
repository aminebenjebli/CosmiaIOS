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

    func saveSession(userId: String, accessToken: String, username: String, password: String, email: String, dateOfBirth: Date?, matches: [String], gender: String) {
        let newSession = Session(context: context)
        newSession.id = UUID()
        newSession.userId = userId
        newSession.accessToken = accessToken
        newSession.username = username
        newSession.password = password
        newSession.email = email
        newSession.gender = gender

        if let dateOfBirth = dateOfBirth {
            newSession.dateOfBirth = dateOfBirth
        } else if let decodedDOB = decodeDateOfBirthFromToken(token: accessToken) {
            newSession.dateOfBirth = decodedDOB
        } else {
            newSession.dateOfBirth = Date()
        }

        if let decodedMatches = decodeMatchesFromToken(token: accessToken) {
            if let matchesData = try? JSONEncoder().encode(decodedMatches),
               let matchesString = String(data: matchesData, encoding: .utf8) {
                newSession.matches = matchesString
            } else {
                newSession.matches = "[]"
            }
        } else {
            newSession.matches = "[]"
        }

        newSession.createdAt = Date()

        do {
            try context.save()
            print("[SessionManager] Session saved successfully!")
        } catch {
            print("[SessionManager] Failed to save session: \(error.localizedDescription)")
        }
    }

    func getActiveSession() -> Session? {
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()

        do {
            let sessions = try context.fetch(fetchRequest)
            guard let session = sessions.sorted(by: { $0.createdAt ?? Date.distantPast > $1.createdAt ?? Date.distantPast }).first else {
                return nil
            }

            if let createdAt = session.createdAt,
               Date().timeIntervalSince(createdAt) <= sessionExpiryInterval {
                return session
            } else {
                deleteSession(session)
                return nil
            }
        } catch {
            return nil
        }
    }

    func updateSession(session: Session, username: String, email: String, dateOfBirth: Date, gender: String,matches: String) {
        session.username = username
        session.email = email
        session.dateOfBirth = dateOfBirth
        session.gender = gender
        session.matches = matches

        do {
            try context.save()
            print("[SessionManager] Session updated successfully!")
        } catch {
            print("[SessionManager] Failed to update session: \(error.localizedDescription)")
        }
    }

    func decodeGenderFromToken(token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let gender = json["gender"] as? String else { return nil }

        return gender
    }

    func decodeMatchesFromToken(token: String) -> [String]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = segments[1]
        let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
        let base64Padded = payloadSegment.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64Padded),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let matches = json["matches"] as? [String] else { return nil }

        return matches
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
              let dobString = json["dateOfBirth"] as? String else { return nil }

        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: dobString)
    }

    func deleteSession(_ session: Session) {
        context.delete(session)
        do {
            try context.save()
        } catch {
            print("[SessionManager] Failed to delete session: \(error.localizedDescription)")
        }
    }
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
}
