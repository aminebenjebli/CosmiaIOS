import SwiftUI

struct FeedbackSupportView: View {
    @State private var feedbackText: String = ""
    @State private var selectedRating: Int? = nil // State to track selected rating
    @State private var showSuccessMessage: Bool = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Top Section
                VStack(alignment: .leading, spacing: 10) {
                    
                    
                    Text("Feedback & Support")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top)

                    Text("We value your feedback! Let us know if you have any suggestions or issues.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal)

                Spacer().frame(height: 30)

                // Star Rating Section
                VStack(alignment: .center, spacing: 10) {
                    Text("Rate Us")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= (selectedRating ?? 0) ? "star.fill" : "star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(star <= (selectedRating ?? 0) ? .yellow : .white.opacity(0.6))
                                .onTapGesture {
                                    selectedRating = star
                                }
                                .shadow(radius: 3)
                        }
                    }
                }

                Spacer().frame(height: 30)

                // Feedback Text Editor
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Feedback")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextEditor(text: $feedbackText)
                        .frame(height: 150)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                Spacer().frame(height: 20)

                // Submit Button
                Button(action: {
                    sendFeedback()
                }) {
                    Text("Submit")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.indigo, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)

                Spacer()

                // Footer
                Text("Thank you for helping us improve!")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Thank You!"), message: Text("Your feedback has been submitted."), dismissButton: .default(Text("OK")))
        }
    }

    private func sendFeedback() {
        // Add feedback submission logic here
        print("Feedback Text: \(feedbackText)")
        print("Rating: \(selectedRating ?? 0)")
        feedbackText = ""
        selectedRating = nil
        showSuccessMessage = true
    }
}

#Preview {
    FeedbackSupportView()
}
