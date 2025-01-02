import Foundation
import Combine
import UserNotifications

class FeedsViewModel: ObservableObject {
    @Published var dailyFeed: FeedModel? // Use updated FeedModel
    @Published var dailyImageURL: URL?
    @Published var feedHistory: [FeedModel] = [] // Use updated FeedModel
    @Published var countdownText: String = ""
    private var timer: AnyCancellable?
    
    private let backendEndpoint = "http://localhost:3000/feedsgen"

    init() {
        startCountdownTimer()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("[FeedsViewModel] Notifications granted.")
            }
        }
    }
    private func startCountdownTimer() {
           timer = Timer.publish(every: 1, on: .main, in: .common)
               .autoconnect()
               .sink { [weak self] _ in
                   self?.updateCountdown()
               }
       }

       private func updateCountdown() {
           let calendar = Calendar.current
           let now = Date()
           if let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) {
               let remainingTime = Int(nextMidnight.timeIntervalSince(now))
               let hours = remainingTime / 3600
               let minutes = (remainingTime % 3600) / 60
               let seconds = remainingTime % 60
               countdownText = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
           } else {
               countdownText = "00:00:00"
           }
       }
    func fetchDailyFeed() {
        guard let session = SessionManager.shared.getActiveSession(),
              let email = session.email,
              let dateOfBirth = session.dateOfBirth else {
            print("[FeedsViewModel] Error: No active session or missing user data.")
            return
        }

        fetchLastFeedFromBackend(email: email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let feed):
                    if !self!.isBeforeMidnight(feed.createdAt) {
                        print("[FeedsViewModel] Found today's feed: \(feed)")
                        self?.dailyFeed = feed
                        self?.dailyImageURL = URL(string: feed.image)
                    } else {
                        print("[FeedsViewModel] Found expired feed. Regenerate feed.")
                        self?.generateDailyFeed(for: feed.zodiacSign, email: email)
                    }
                case .failure(let error):
                    print("[FeedsViewModel] Failed to fetch feed: \(error.localizedDescription)")
                    self?.generateDailyFeed(for: self?.determineZodiacSign(from: dateOfBirth) ?? "", email: email)
                }
            }
        }
    }

    func fetchFeedHistory(email: String) {
        guard let url = URL(string: "\(backendEndpoint)/history/\(email)") else {
            print("[FeedsViewModel] Invalid history URL.")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[FeedsViewModel] Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("[FeedsViewModel] No data received for history.")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601WithMilliseconds)
                let feeds = try decoder.decode([FeedModel].self, from: data)
                DispatchQueue.main.async {
                    self.feedHistory = feeds
                }
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("[FeedsViewModel] Type mismatch for type \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("[FeedsViewModel] Value not found for type \(type): \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("[FeedsViewModel] Key '\(key)' not found: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("[FeedsViewModel] Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("[FeedsViewModel] Unknown decoding error: \(decodingError)")
                }
            } catch {
                print("[FeedsViewModel] Unknown error: \(error.localizedDescription)")
            }
        }.resume()
    }
    private func fetchLastFeedFromBackend(email: String, completion: @escaping (Result<FeedModel, Error>) -> Void) {
        guard let url = URL(string: "\(backendEndpoint)/\(email)") else {
            print("[FeedsViewModel] Invalid backend URL.")
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        print("[FeedsViewModel] Sending request to \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[FeedsViewModel] Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("[FeedsViewModel] No data received from server.")
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }

            // Log raw JSON response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("[FeedsViewModel] Raw response: \(rawResponse)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601WithMilliseconds)
                let feed = try decoder.decode(FeedModel.self, from: data)
                completion(.success(feed))
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("[FeedsViewModel] Type mismatch for type \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("[FeedsViewModel] Value not found for type \(type): \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("[FeedsViewModel] Key '\(key)' not found: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("[FeedsViewModel] Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("[FeedsViewModel] Unknown decoding error: \(decodingError)")
                }
                completion(.failure(decodingError))
            } catch {
                print("[FeedsViewModel] Unknown error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func generateDailyFeed(for zodiacSign: String, email: String) {
        let prompt = """
        Generate a daily horoscope for the zodiac sign \(zodiacSign). Include:
        - A positive or realistic prediction.
        - A lucky number.
        - A lucky color.
        Format your response as:
        Zodiac Sign: \(zodiacSign)
        Message: {message}
        Lucky Number: {number}
        Lucky Color: {color}
        """

        let request = makeOpenAIRequest(prompt: prompt)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
               let content = result.choices.first?.message.content {
                let parsedFeed = self.parseResponse(content, for: zodiacSign)
                if let feed = parsedFeed {
                    self.generateImage(for: feed.zodiacSign, message: feed.description) { imageResult in
                        DispatchQueue.main.async {
                            switch imageResult {
                            case .success(let imageUrl):
                                // Create a new instance of FeedModel with the image URL
                                let now = Date()
                                let completeFeed = FeedModel(
                                    id: UUID().uuidString, // Generate a new UUID for the feed
                                    email: email,
                                    zodiacSign: feed.zodiacSign,
                                    luckyNumber: feed.luckyNumber,
                                    luckyColor: feed.luckyColor,
                                    description: feed.description,
                                    image: imageUrl,
                                    createdAt: now, // Use the current date
                                    updatedAt: now // Default to the same as createdAt
                                )
                                self.dailyFeed = completeFeed
                                self.dailyImageURL = URL(string: imageUrl)
                                self.uploadFeedToBackend(feed: completeFeed, email: email)
                            case .failure(let error):
                                print("[FeedsViewModel] Failed to generate image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } else {
                print("[FeedsViewModel] Failed to decode OpenAI response or received invalid data.")
            }
        }.resume()
    }
    private func uploadFeedToBackend(feed: FeedModel, email: String) {
        guard let url = URL(string: "\(backendEndpoint)/create"),
              let imageURL = URL(string: feed.image) else {
            print("[FeedsViewModel] Invalid upload URL or image URL.")
            return
        }

        // Fetch the image data from the URL
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            guard let imageData = data else {
                print("[FeedsViewModel] Failed to fetch image data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            let addField: (String, String) -> Void = { name, value in
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }

            addField("email", email)
            addField("zodiacSign", feed.zodiacSign)
            addField("luckyNumber", "\(feed.luckyNumber)")
            addField("luckyColor", feed.luckyColor)
            addField("description", feed.description)

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("[FeedsViewModel] Upload error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[FeedsViewModel] Invalid response from server.")
                    return
                }

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("[FeedsViewModel] Feed uploaded successfully.")
                } else {
                    print("[FeedsViewModel] Failed to upload feed. Status code: \(httpResponse.statusCode)")
                }
            }.resume()
        }.resume()
    }

    private func makeOpenAIRequest(prompt: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful astrology expert."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 200,
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func generateImage(for zodiacSign: String, message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = "An artistic representation of \(zodiacSign), \(message)."
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": "512x512"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let result = try? JSONDecoder().decode(OpenAIImageResponse.self, from: data),
               let imageUrl = result.data.first?.url {
                completion(.success(imageUrl))
            } else {
                completion(.failure(error ?? NSError(domain: "Image Generation Error", code: -1, userInfo: nil)))
            }
        }.resume()
    }

    private func parseResponse(_ response: String, for zodiacSign: String) -> FeedModel? {
        let components = response.split(separator: "\n").map { $0.split(separator: ":").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
        var message = ""
        var luckyNumber = 0
        var luckyColor = ""

        for component in components {
            if component.count == 2 {
                switch component[0] {
                case "Message":
                    message = component[1]
                case "Lucky Number":
                    luckyNumber = Int(component[1]) ?? 0
                case "Lucky Color":
                    luckyColor = component[1]
                default:
                    break
                }
            }
        }

        guard !message.isEmpty, luckyNumber != 0, !luckyColor.isEmpty else { return nil }

        let now = Date()
        return FeedModel(
            id: UUID().uuidString, // Temporary ID
            email: "", // Will be populated elsewhere
            zodiacSign: zodiacSign,
            luckyNumber: luckyNumber,
            luckyColor: luckyColor,
            description: message,
            image: "", // Will be updated with the generated image URL
            createdAt: now,
            updatedAt: now // Default to the same as createdAt
        )
    }
    private func isBeforeMidnight(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())
    }

    private func determineZodiacSign(from date: Date) -> String? {
        let zodiacSigns = [
            ("Capricorn", (start: "12-22", end: "01-19")),
            ("Aquarius", (start: "01-20", end: "02-18")),
            ("Pisces", (start: "02-19", end: "03-20")),
            ("Aries", (start: "03-21", end: "04-19")),
            ("Taurus", (start: "04-20", end: "05-20")),
            ("Gemini", (start: "05-21", end: "06-20")),
            ("Cancer", (start: "06-21", end: "07-22")),
            ("Leo", (start: "07-23", end: "08-22")),
            ("Virgo", (start: "08-23", end: "09-22")),
            ("Libra", (start: "09-23", end: "10-22")),
            ("Scorpio", (start: "10-23", end: "11-21")),
            ("Sagittarius", (start: "11-22", end: "12-21"))
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"

        let dateString = formatter.string(from: date)
        let dateComponents = dateString.split(separator: "-").map { Int($0)! }

        for (sign, range) in zodiacSigns {
            let startComponents = range.start.split(separator: "-").map { Int($0)! }
            let endComponents = range.end.split(separator: "-").map { Int($0)! }

            if (dateComponents[0] == startComponents[0] && dateComponents[1] >= startComponents[1]) ||
                (dateComponents[0] == endComponents[0] && dateComponents[1] <= endComponents[1]) ||
                (startComponents[0] < endComponents[0] && (dateComponents[0] > startComponents[0] && dateComponents[0] < endComponents[0])) {
                return sign
            }
        }
        return nil
    }

    struct OpenAIResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }

    struct OpenAIImageResponse: Codable {
        struct Data: Codable {
            let url: String
        }
        let data: [Data]
    }
    
}
