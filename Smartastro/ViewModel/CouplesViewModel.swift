import Foundation
import Combine

class CouplesViewModel: ObservableObject {
    @Published var isCouple: Bool = false
    @Published var isLoading: Bool = false
    @Published var coupleData: Couple? = nil
    @Published var errorMessage: String? = nil
    @Published var eitherIsCoupled: Bool = false

    private let apiUrl = "http://localhost:3000/couples"
    private var cancellables = Set<AnyCancellable>()

    struct Couple: Decodable {
        let senderId: String
        let receiverId: String
        let status: String
    }

    struct CoupleStatusResponse: Decodable {
        let isCoupled: Bool
        let couple: Couple?
    }

    func checkCoupleStatusForBoth(userId: String, receiverId: String) {
        let group = DispatchGroup()

        var userIsCoupled = false
        var receiverIsCoupled = false

        group.enter()
        fetchIsCoupled(for: userId) { isCoupled in
            userIsCoupled = isCoupled
            group.leave()
        }

        group.enter()
        fetchIsCoupled(for: receiverId) { isCoupled in
            receiverIsCoupled = isCoupled
            group.leave()
        }

        group.notify(queue: .main) {
            self.eitherIsCoupled = userIsCoupled || receiverIsCoupled
            self.isCouple = userIsCoupled && receiverIsCoupled
        }
    }

    private func fetchIsCoupled(for userId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(apiUrl)/isCoupled/\(userId)") else {
            completion(false)
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CoupleStatusResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case .failure = result {
                    completion(false)
                }
            }, receiveValue: { response in
                completion(response.isCoupled)
            })
            .store(in: &cancellables)
    }

    func checkCoupleStatus(userId: String, receiverId: String) {
        guard let url = URL(string: "\(apiUrl)/status?userId=\(userId)&receiverId=\(receiverId)") else { return }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CoupleStatusResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to fetch couple status: \(error.localizedDescription)"
                }
            }, receiveValue: { response in
                self.isCouple = response.isCoupled
                self.coupleData = response.couple
            })
            .store(in: &cancellables)
    }

    func sendCoupleRequest(senderId: String, receiverId: String) {
        guard let url = URL(string: "\(apiUrl)/request") else { return }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["senderId": senderId, "receiverId": receiverId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to send couple request: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func fetchRequests(userId: String, completion: @escaping ([Couple]) -> Void) {
        guard let url = URL(string: "\(apiUrl)/requests/\(userId)") else { return }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Couple].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                self.isLoading = false
                if case .failure = completionResult {
                    self.errorMessage = "Failed to fetch couple requests"
                }
            }, receiveValue: { requests in
                completion(requests)
            })
            .store(in: &cancellables)
    }

    func fetchCouples(userId: String, completion: @escaping ([Couple]) -> Void) {
        guard let url = URL(string: "\(apiUrl)/couples/\(userId)") else { return }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Couple].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                self.isLoading = false
                if case .failure = completionResult {
                    self.errorMessage = "Failed to fetch couples"
                }
            }, receiveValue: { couples in
                completion(couples)
            })
            .store(in: &cancellables)
    }
}
