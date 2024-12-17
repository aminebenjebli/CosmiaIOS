import SwiftUI
import Combine
import PhotosUI

class StoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let uploadUrl = "http://localhost:3000/album/upload-image"
    private let fetchUrl = "http://localhost:3000/album"
    private var cancellables = Set<AnyCancellable>()

    func fetchStories() {
        isLoading = true
        guard let email = SessionManager.shared.getActiveSession()?.email else {
            self.errorMessage = "No active session found."
            return
        }

        URLSession.shared.dataTaskPublisher(for: URL(string: fetchUrl)!)
            .map(\.data)
            .decode(type: [Album].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to fetch stories: \(error.localizedDescription)"
                }
            } receiveValue: { albums in
                // Group images under each user
                var groupedStories: [String: [String]] = [:]
                albums.forEach { album in
                    groupedStories[album.email, default: []].append(album.image)
                }

                // Map to stories
                self.stories = groupedStories.map { email, images in
                    Story(id: UUID(), name: email == email ? "You" : email, images: images, isCurrentUser: email == email)
                }
            }
            .store(in: &cancellables)
    }

    func uploadStory(image: UIImage) {
        guard let email = SessionManager.shared.getActiveSession()?.email else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        var request = URLRequest(url: URL(string: uploadUrl)!)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n")
        body.append("\(email)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"story.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        isLoading = true
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Album.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Upload failed: \(error.localizedDescription)"
                }
            } receiveValue: { _ in
                self.fetchStories() // Refresh stories after upload
            }
            .store(in: &cancellables)
    }
}

