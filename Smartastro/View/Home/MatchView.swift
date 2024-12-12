import SwiftUI

struct MatchView: View {
    let matchedUserName: String // Name of the matched user

    var onSendMessage: () -> Void // Callback for Send Message action
    var onKeepSwiping: () -> Void // Callback for Keep Swiping action

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Match Text
                VStack {
                    Text("It's a Match!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)

                    Text("You and Ayouta have liked each other.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }

                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: onSendMessage) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                            Text("Send a Message")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }

                    Button(action: onKeepSwiping) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                            Text("Keep Swiping")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

