import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let baseUrl = "http://localhost:3000/message"
    private var cancellables = Set<AnyCancellable>()

    // Fetch messages between the logged-in user and another user
    func fetchMessages(with otherUserId: String) {
        guard let currentSession = SessionManager.shared.getActiveSession(),
              let senderId = currentSession.userId else {
            errorMessage = "No active session or invalid user ID"
            return
        }

        isLoading = true
        guard let url = URL(string: "\(baseUrl)/history?user1Id=\(senderId)&user2Id=\(otherUserId)") else {
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Message].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] messages in
                self?.messages = messages
            })
            .store(in: &cancellables)
    }

    // Send a new message from the logged-in user
    func sendMessage(to receiverId: String, content: String) {
        guard let currentSession = SessionManager.shared.getActiveSession(),
              let senderId = currentSession.userId else {
            print("No active session or invalid user ID")
            return
        }

        let messagePayload = ["senderId": senderId, "receiverId": receiverId, "content": content]
        guard let url = URL(string: "\(baseUrl)/send") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: messagePayload)
        } catch {
            print("Failed to encode message payload.")
            return
        }

        // Add the message locally before the server responds
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            read: false
        )
        DispatchQueue.main.async {
            self.messages.append(newMessage) // Instantly add the message to the UI
        }

        // Send the message to the server
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to send message: \(error.localizedDescription)")
            }
        }.resume()
    }

}
