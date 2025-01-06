import Foundation
import Combine


enum CallType {
    case video
    case phone
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var roomId: String? = nil // Store the current roomId
    @Published var rtcToken: String? = nil // RTC Token for video call
       @Published var rtmToken: String? = nil
    private let baseUrl = "http://localhost:3000/chat"
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch or create a room for the current user and another user
    func getOrCreateRoom(with otherUserId: String, completion: @escaping (String?) -> Void) {
        guard let currentSession = SessionManager.shared.getActiveSession(),
              let userId = currentSession.userId else {
            errorMessage = "No active session or invalid user ID"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            completion(nil)
            return
        }
        
        let payload = ["userId1": userId, "userId2": otherUserId]
        print("[ChatViewModel] Sending request to get or create room with payload: \(payload)")
        
        guard let url = URL(string: "\(baseUrl)/getOrCreateRoom") else {
            errorMessage = "Invalid URL"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            errorMessage = "Failed to encode payload"
            print("[ChatViewModel] Error encoding payload: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [String: String].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                if case .failure(let error) = completionStatus {
                    self?.errorMessage = "Failed to get or create room: \(error.localizedDescription)"
                    print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                    completion(nil)
                }
            }, receiveValue: { [weak self] response in
                if let roomId = response["roomId"] {
                    self?.roomId = roomId
                    print("[ChatViewModel] Room found/created with ID: \(roomId)")
                    completion(roomId)
                } else {
                    self?.errorMessage = "Room ID not found in response"
                    print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                    completion(nil)
                }
            })
            .store(in: &cancellables)
    }
    
    // Fetch messages for the given roomId
    func fetchMessages(roomId: String) {
        guard !roomId.isEmpty else {
            errorMessage = "Invalid room ID"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            return
        }
        
        isLoading = true
        print("[ChatViewModel] Fetching messages for room ID: \(roomId)")
        
        guard let url = URL(string: "\(baseUrl)/messages/\(roomId)") else {
            errorMessage = "Invalid URL"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
                    print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                    return
                }
                
                // Log the raw response data
                if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                    print("[ChatViewModel] Raw response: \(rawResponse)")
                } else {
                    print("[ChatViewModel] No data received from server.")
                    self?.errorMessage = "No data received from server"
                    return
                }
                
                // Attempt to decode the data
                guard let data = data else { return }
                do {
                    var messages = try JSONDecoder().decode([Message].self, from: data)
                    messages = messages.filter { $0.senderId != nil && $0.receiverId != nil && $0.content != nil }
                    self?.messages = messages
                    print("[ChatViewModel] Messages fetched successfully: \(messages)")
                } catch {
                    self?.errorMessage = "Failed to decode messages: \(error.localizedDescription)"
                    print("[ChatViewModel] Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    // Send a new message
    func sendMessage(to receiverId: String, content: String) {
        // Ensure we have a valid room ID
        guard let roomId = roomId else {
            errorMessage = "No active chat room"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            return
        }
        
        // Ensure the current user is logged in
        guard let currentSession = SessionManager.shared.getActiveSession(),
              let senderId = currentSession.userId else {
            errorMessage = "No active session or invalid user ID"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            return
        }
        
        // Prepare the payload
        let payload: [String: Any] = [
            "roomId": roomId,
            "senderId": senderId,
            "receiverId": receiverId,
            "message": content
        ]
        print("[ChatViewModel] Preparing to send message with payload: \(payload)")
        
        // Validate the URL
        guard let url = URL(string: "\(baseUrl)/send") else {
            errorMessage = "Invalid URL"
            print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
            return
        }
        
        // Create and configure the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            print("[ChatViewModel] Message payload successfully encoded.")
        } catch {
            errorMessage = "Failed to encode message payload"
            print("[ChatViewModel] Error encoding message payload: \(error.localizedDescription)")
            return
        }
        
        // Add the message locally before sending to the server
        let newMessage = Message(
            id: UUID().uuidString, // Temporary ID for local use
            roomId: roomId,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        DispatchQueue.main.async {
            self.messages.append(newMessage)
            print("[ChatViewModel] Message added locally: \(newMessage)")
        }
        
        // Send the message to the server
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to send message: \(error.localizedDescription)"
                    print("[ChatViewModel] Error: \(self.errorMessage ?? "Unknown error")")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 201 {
                        print("[ChatViewModel] Message sent successfully to server.")
                    } else {
                        print("[ChatViewModel] Unexpected response status code: \(response.statusCode)")
                    }
                }
                
                // Log the raw server response
                if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                    print("[ChatViewModel] Server response: \(rawResponse)")
                } else {
                    print("[ChatViewModel] No data received from server.")
                }
            }
        }.resume()
    }
    func fetchRtcToken(channelName: String, completion: @escaping (String?) -> Void) {
           guard let currentSession = SessionManager.shared.getActiveSession(),
                 let userId = currentSession.userId else {
               errorMessage = "No active session or invalid user ID"
               print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
               completion(nil)
               return
           }

           guard let url = URL(string: "\(baseUrl)/agora/rtc-token?channelName=\(channelName)&userId=\(userId)") else {
               errorMessage = "Invalid RTC Token URL"
               print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
               completion(nil)
               return
           }

           URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
               if let error = error {
                   self?.errorMessage = "Failed to fetch RTC token: \(error.localizedDescription)"
                   print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                   completion(nil)
                   return
               }

               guard let data = data else {
                   self?.errorMessage = "No data received for RTC token"
                   print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                   completion(nil)
                   return
               }

               do {
                   let token = try JSONDecoder().decode(AgoraRtcToken.self, from: data)
                   self?.rtcToken = token.token
                   print("[ChatViewModel] RTC Token fetched: \(token.token)")
                   completion(token.token)
               } catch {
                   self?.errorMessage = "Failed to decode RTC token: \(error.localizedDescription)"
                   print("[ChatViewModel] Decoding Error: \(error)")
                   completion(nil)
               }
           }.resume()
       }

       // Fetch RTM token for messaging or signaling
       func fetchRtmToken(completion: @escaping (String?) -> Void) {
           guard let currentSession = SessionManager.shared.getActiveSession(),
                 let userId = currentSession.userId else {
               errorMessage = "No active session or invalid user ID"
               print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
               completion(nil)
               return
           }

           guard let url = URL(string: "\(baseUrl)/agora/rtm-token?userId=\(userId)") else {
               errorMessage = "Invalid RTM Token URL"
               print("[ChatViewModel] Error: \(errorMessage ?? "Unknown error")")
               completion(nil)
               return
           }

           URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
               if let error = error {
                   self?.errorMessage = "Failed to fetch RTM token: \(error.localizedDescription)"
                   print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                   completion(nil)
                   return
               }

               guard let data = data else {
                   self?.errorMessage = "No data received for RTM token"
                   print("[ChatViewModel] Error: \(self?.errorMessage ?? "Unknown error")")
                   completion(nil)
                   return
               }

               do {
                   let token = try JSONDecoder().decode(AgoraRtmToken.self, from: data)
                   self?.rtmToken = token.token
                   print("[ChatViewModel] RTM Token fetched: \(token.token)")
                   completion(token.token)
               } catch {
                   self?.errorMessage = "Failed to decode RTM token: \(error.localizedDescription)"
                   print("[ChatViewModel] Decoding Error: \(error)")
                   completion(nil)
               }
           }.resume()
       }

       // Send a new call message
       func sendCallMessage(to receiverId: String, type: CallType) {
           let messageContent = type == .video ? "Started a video call" : "Started a phone call"
           sendMessage(to: receiverId, content: messageContent)
       }
}
