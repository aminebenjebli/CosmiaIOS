import Combine
import _PhotosUI_SwiftUI
import UIKit
struct IdentifiableImage: Identifiable {
    let id: UUID
    let image: UIImage
}
class AlbumViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var isAlbumSaved: Bool = false // To track if album is saved successfully
    @Published var albumImages: [String] = []  // Array to hold image URLs
    @Published var isLoading: Bool = false // To indicate if album images are loading
    @Published var errorMessage: String? = nil // To show any errors
    @Published var selectedPhotos: [PhotosPickerItem] = []  // Add this property

    private var cancellables = Set<AnyCancellable>()
    private let apiUrl = "http://localhost:3000/album" // Your backend URL

    // MARK: - Add, Remove, and Save Image
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }

    func removeImage(image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        }
    }

    func saveAlbum() {
        guard let email = SessionManager.shared.getActiveSession()?.email else {
            print("No active session found.")
            return
        }

        guard !selectedImages.isEmpty else {
            print("No images selected.")
            return
        }

        for image in selectedImages {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to Data.")
                return
            }

            var request = URLRequest(url: URL(string: apiUrl + "/upload-image")!)
            request.httpMethod = "POST"
            
            // Setting content type to multipart/form-data
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()

            // Adding email to the body
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n")
            body.append("\(email)\r\n")

            // Adding the image data to the body
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")

            // Closing boundary
            body.append("--\(boundary)--\r\n")

            request.httpBody = body

            // Making the network request to the backend
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .sink { completion in
                    switch completion {
                    case .finished:
                        DispatchQueue.main.async {
                            self.isAlbumSaved = true // Album saved successfully
                            self.selectedImages.removeAll() // Clear selected images
                        }
                        print("Album saved successfully.")
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.isAlbumSaved = false // Failed to save album
                            self.errorMessage = error.localizedDescription
                        }
                        print("Failed to save album: \(error)")
                    }
                } receiveValue: { (albumData: Data) in
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: albumData, options: []) {
                        print("Backend Response: \(jsonResponse)")  // For debugging
                    }

                    do {
                        let album = try JSONDecoder().decode(Album.self, from: albumData)
                        print("Album created with image URL: \(album.image)") // Here you get the image URL
                    } catch {
                        print("Error decoding response: \(error)")
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Fetch Album Images
    func fetchAlbumImages() {
        guard let email = SessionManager.shared.getActiveSession()?.email else {
            print("No active session found.")
            return
        }

        isLoading = true // Start loading
        
        let url = URL(string: "\(apiUrl)/\(email)")!

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .sink { completion in
                self.isLoading = false // End loading
                switch completion {
                case .finished:
                    print("Fetched album images successfully.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Failed to fetch album images: \(error)")
                }
            } receiveValue: { (albumData: Data) in
                do {
                    // Decode the response into an array of ImageData objects
                    let images = try JSONDecoder().decode([ImageData].self, from: albumData)

                    // Update the albumImages array with the image URLs
                    DispatchQueue.main.async {
                        self.albumImages = images.map { $0.image }
                        print("Album Images Fetched: \(self.albumImages)") // Debug log
                    }
                } catch {
                    self.errorMessage = "Failed to decode album data"
                    print("Error decoding response: \(error)")
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Delete Image
    func deleteImage(imageUrl: String) {
        guard let email = SessionManager.shared.getActiveSession()?.email else {
            print("No active session found.")
            return
        }

        var request = URLRequest(url: URL(string: "\(apiUrl)/delete-image/\(email)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["imageUrl": imageUrl]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Failed to delete image: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            // If the deletion is successful, remove the image from the local albumImages array
            DispatchQueue.main.async {
                self.albumImages.removeAll { $0 == imageUrl }
            }
        }.resume()
    }
}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    mutating func append(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            append(data)
        }
    }
}
