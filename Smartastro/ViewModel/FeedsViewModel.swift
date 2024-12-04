import Foundation
import UserNotifications
import BackgroundTasks

class FeedsViewModel: ObservableObject {
    @Published var dailyFeed: ZodiacFeed? // Current horoscope
    @Published var newDailyFeed: ZodiacFeed? // New horoscope after midnight
    @Published var dailyImageURL: URL? // Image for the current horoscope
    @Published var newDailyImageURL: URL? // Image for the new horoscope

    private let openAIAPIKey = "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"

    init() {
        requestNotificationAuthorization()
        registerBackgroundTask()
        loadStoredFeeds()
        scheduleDailyGenerationIfNeeded()
    }

    func fetchDailyFeed(isNew: Bool = false) {
        guard let session = SessionManager.shared.getActiveSession(),
              let dateOfBirth = session.dateOfBirth else { return }

        guard let zodiacSign = determineZodiacSign(from: dateOfBirth) else { return }

        let prompt = """
        Generate a daily horoscope for the zodiac sign \(zodiacSign). Include:
        - A positive or realistic prediction.
        - A lucky number.
        - A lucky color.
        Format your response as:
        Zodiac Sign: {zodiacSign}
        Message: {message}
        Lucky Number: {number}
        Lucky Color: {color}
        """

        let request = makeOpenAIRequest(prompt: prompt)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error { return }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let content = result.choices.first?.message.content {
                    DispatchQueue.main.async {
                        let parsedFeed = self?.parseResponse(content, for: zodiacSign)
                        if isNew {
                            self?.newDailyFeed = parsedFeed
                            if let feed = parsedFeed {
                                self?.fetchImage(for: feed.zodiacSign, message: feed.message, isNew: true)
                                self?.saveFeedToStorage(feed: feed, isNew: true)
                                self?.scheduleNotification()
                            }
                        } else {
                            self?.dailyFeed = parsedFeed
                            if let feed = parsedFeed {
                                self?.fetchImage(for: feed.zodiacSign, message: feed.message, isNew: false)
                                self?.saveFeedToStorage(feed: feed, isNew: false)
                            }
                        }
                    }
                }
            } catch {}
        }.resume()
    }

    private func makeOpenAIRequest(prompt: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
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

    private func fetchImage(for zodiacSign: String, message: String, isNew: Bool) {
        let prompt = "An artistic representation of \(zodiacSign), \(message)."
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": "512x512"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error { return }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
                if let imageUrlString = result.data.first?.url,
                   let imageUrl = URL(string: imageUrlString) {
                    DispatchQueue.main.async {
                        if isNew {
                            self?.newDailyImageURL = imageUrl
                        } else {
                            self?.dailyImageURL = imageUrl
                        }
                    }
                }
            } catch {}
        }.resume()
    }

    private func parseResponse(_ response: String, for zodiacSign: String) -> ZodiacFeed {
        let components = response.split(separator: "\n").map { $0.split(separator: ":").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }

        var message = ""
        var luckyNumber = ""
        var luckyColor = ""

        for component in components {
            if component.count == 2 {
                switch component[0] {
                case "Message":
                    message = component[1]
                case "Lucky Number":
                    luckyNumber = component[1]
                case "Lucky Color":
                    luckyColor = component[1]
                default:
                    break
                }
            }
        }
        return ZodiacFeed(zodiacSign: zodiacSign, message: message, luckyNumber: luckyNumber, luckyColor: luckyColor)
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

    private func loadStoredFeeds() {
        if let data = UserDefaults.standard.data(forKey: "dailyFeed"),
           let storedFeed = try? JSONDecoder().decode(ZodiacFeed.self, from: data) {
            dailyFeed = storedFeed
        }
        if let data = UserDefaults.standard.data(forKey: "newDailyFeed"),
           let storedNewFeed = try? JSONDecoder().decode(ZodiacFeed.self, from: data) {
            newDailyFeed = storedNewFeed
        }
    }

    private func saveFeedToStorage(feed: ZodiacFeed, isNew: Bool) {
        let key = isNew ? "newDailyFeed" : "dailyFeed"
        if let data = try? JSONEncoder().encode(feed) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func shouldGenerateNewFeed() -> Bool {
        let lastGenerationDate = UserDefaults.standard.object(forKey: "lastGenerationDate") as? Date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastGenerationDate, calendar.isDate(lastDate, inSameDayAs: today) {
            return false
        }
        return true
    }

    private func saveLastGenerationDate() {
        UserDefaults.standard.set(Date(), forKey: "lastGenerationDate")
    }

    private func scheduleDailyGenerationIfNeeded() {
        if shouldGenerateNewFeed() {
            fetchDailyFeed(isNew: true)
        }
    }

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Your New Daily Horoscope is Ready! 🌟"
        content.body = "Tap to check your updated lucky number, color, and predictions!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyHoroscopeNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.dailyHoroscopeRefresh", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
    }

    private func handleBackgroundTask(task: BGAppRefreshTask) {
        fetchDailyFeed(isNew: true)
        task.setTaskCompleted(success: true)
    }

    struct ZodiacFeed: Codable {
        let zodiacSign: String
        let message: String
        let luckyNumber: String
        let luckyColor: String
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
