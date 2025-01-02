//
//  TopicViewModel.swift
//  Smartastro
//
//  Created by Aziz on 12/30/24.
//

import Foundation
import Combine

class TopicViewModel: ObservableObject {
    @Published var topics: [String] = []
    @Published var isLoading: Bool = false

    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    private let apiKey = "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" // Replace with your OpenAI API key
    private var cancellables = Set<AnyCancellable>()

    func fetchTopics(category: String = "getting to know each other") {
        isLoading = true
        topics = []

        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an AI designed to suggest short and engaging conversation topics for people to better know each other, potentially forming meaningful connections or relationships."],
            ["role": "user", "content": "Generate 5 short and concise conversation topics about \(category). Keep each topic as a short phrase or single question."]
        ]

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "max_tokens": 100,
            "temperature": 0.7
        ]

        guard let url = URL(string: apiUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to encode body: \(error.localizedDescription)")
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GPTChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching topics: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                let generatedText = response.choices.first?.message.content ?? ""
                self.topics = generatedText
                    .components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            })
            .store(in: &cancellables)
    }
}

struct GPTChatResponse: Decodable {
    let choices: [GPTChatChoice]
}

struct GPTChatChoice: Decodable {
    let message: GPTChatMessage
}

struct GPTChatMessage: Decodable {
    let content: String
}
