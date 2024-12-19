//import Foundation
//import Combine
//import SocketIo
//
//class ChatViewModel: ObservableObject {
//    @Published var messages: [Message] = []
//    @Published var errorMessage: String?
//    @Published var isLoading: Bool = false
//    
//    private let baseUrl = "http://localhost:3000/message"
//    private let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
//    private var socket: SocketIOClient
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        socket = manager.defaultSocket
//        setupSocketListeners()
//    }
//    
//    // MARK: - Fetch Messages
//    func fetchMessages(with userId: String, otherUserId: String) {
//        isLoading = true
//        let url = URL(string: "\(baseUrl)/history?user1Id=\(userId)&user2Id=\(otherUserId)")!
//        
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: [Message].self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.isLoading = false
//                if case .failure(let error) = completion {
//                    self?.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
//                }
//            }, receiveValue: { [weak self] messages in
//                self?.messages = messages
//            })
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - Send Message
//    func sendMessage(senderId: String, receiverId: String, content: String) {
//        socket.emit("message", ["senderId": senderId, "receiverId": receiverId, "content": content])
//    }
//    
//    // MARK: - Socket Setup
//    func joinChat(userId: String) {
//        socket.emit("join", ["userId": userId])
//    }
//    
//    private func setupSocketListeners() {
//        socket.on("message") { [weak self] data, _ in
//            guard let self = self,
//                  let messageData = try? JSONSerialization.data(withJSONObject: data[0]),
//                  let message = try? JSONDecoder().decode(Message.self, from: messageData) else {
//                return
//            }
//            DispatchQueue.main.async {
//                self.messages.append(message)
//            }
//        }
//    }
//    
//    func connectSocket() {
//        socket.connect()
//    }
//    
//    func disconnectSocket() {
//        socket.disconnect()
//    }
//}
