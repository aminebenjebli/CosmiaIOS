import SwiftUI

struct MatchView: View {
    let userImage: String // URL or image name for the current user
    let matchedUserImage: String // URL or image name for the matched user
    let matchedUserName: String // Name of the matched user

    var onSendMessage: () -> Void // Callback for Send Message action
    var onKeepSwiping: () -> Void // Callback for Keep Swiping action

    var body: some View {
        ZStack {
            // Background Color
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

                    Text("You and \(matchedUserName) have liked each other.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }

                // User Images
                HStack(spacing: 20) {
                    // Current User Image
                    AsyncImage(url: URL(string: userImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("You").foregroundColor(.white))
                    }

                    // Matched User Image
                    AsyncImage(url: URL(string: matchedUserImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("Matched").foregroundColor(.white))
                    }
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

#Preview {
    MatchView(
        userImage: "https://example.com/user.jpg",
        matchedUserImage: "https://example.com/matched.jpg",
        matchedUserName: "Jessica Parker",
        onSendMessage: { print("Send Message tapped") },
        onKeepSwiping: { print("Keep Swiping tapped") }
    )
}
