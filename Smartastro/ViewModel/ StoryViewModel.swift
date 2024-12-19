
import Combine
import PhotosUI
import Foundation

class StoryViewModel: ObservableObject {
    @Published var groupedStories: [String: [Story]] = [:]
    @Published var userStories: [Story] = []
    @Published var otherStories: [Story] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseUrl = "http://localhost:3000/stories"
    private let usersUrl = "http://localhost:3000/user"
    private var cancellables = Set<AnyCancellable>()
    
    
    
    func fetchStories() {
        guard let currentUserId = UserSession.shared.userId else {
            errorMessage = "User not logged in."
            return
        }
        
        isLoading = true
        
        // Combine fetching user stories and other users' stories
        Publishers.Zip(fetchUserStories(for: currentUserId), fetchOtherStories(for: currentUserId))
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = "Failed to fetch stories: \(error.localizedDescription)"
                        }
                    } receiveValue: { [weak self] userStories, otherStories in
                        self?.mapUsernamesToStories(stories: otherStories) { updatedStories in
                            self?.groupStories(userStories: userStories, otherStories: updatedStories)
                        }
                    }
                    .store(in: &cancellables)
    }
    
    private func fetchUserStories(for userId: String) -> AnyPublisher<[Story], Error> {
            let url = URL(string: "\(baseUrl)/user/\(userId)")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: [Story].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
    
    private func fetchOtherStories(for currentUserId: String) -> AnyPublisher<[Story], Error> {
            let url = URL(string: "\(baseUrl)/other?currentUserId=\(currentUserId)")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: [Story].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
    private func fetchUsername(for userId: String, completion: @escaping (String?) -> Void) {
            let url = URL(string: "\(usersUrl)/\(userId)")!
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data, let user = try? JSONDecoder().decode(User.self, from: data) {
                    completion(user.username)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    private func mapUsernamesToStories(stories: [Story], completion: @escaping ([Story]) -> Void) {
            let dispatchGroup = DispatchGroup()
            var updatedStories = stories
            
            for (index, story) in stories.enumerated() {
                dispatchGroup.enter()
                fetchUsername(for: story.userId) { username in
                    if let username = username {
                        updatedStories[index].username = username
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(updatedStories)
            }
        }


    // Group stories by userId
    private func groupStories(userStories: [Story], otherStories: [Story]) {
        let grouped = Dictionary(grouping: userStories + otherStories, by: { $0.userId })
        groupedStories = grouped
    }
    // add storie
    func uploadStory(image: UIImage) {
        guard let currentUserId = UserSession.shared.userId else {
            errorMessage = "User not logged in."
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image."
            return
        }

        var request = URLRequest(url: URL(string: "\(baseUrl)/create/\(currentUserId)")!)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"story.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        isLoading = true
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Story.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] _ in
                self?.fetchStories() // Refresh stories
            }
            .store(in: &cancellables)
    }

    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        isLoading = false
        if case .failure(let error) = completion {
            errorMessage = error.localizedDescription
        }
    }
}





