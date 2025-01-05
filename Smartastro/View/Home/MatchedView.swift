import SwiftUI

struct MatchedView: View {
    @StateObject private var viewModel: UserProfileViewModel

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            BackgroundGradientView()

            VStack {
                HStack {
                    CustomBackButton()
                    Spacer()
                }
                .padding()
                
                Spacer(minLength: 10) // Adds space below the back button
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage)
                } else if viewModel.users.isEmpty {
                    NoMatchesView()
                } else {
                    MatchesGridView(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            viewModel.fetchMatches()
        }
        .navigationTitle("Your Matches")
        .navigationBarHidden(true) // Hide default navigation bar
    }
}

struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading matches...")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.5)
    }
}

struct ErrorView: View {
    let errorMessage: String

    var body: some View {
        Text(errorMessage)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct NoMatchesView: View {
    var body: some View {
        Text("No matches found.")
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct MatchesGridView: View {
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) { // Vertical list with spacing
                ForEach(viewModel.users, id: \.id) { user in
                    NavigationLink(
                        destination: ChatView(
                            viewModel: ChatViewModel(),
                            receiverId: user.id ?? "",
                            receiverUsername: user.username
                            
                        )
                    ) {
                        MatchedUserView(user: user)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct MatchedUserView: View {
    let user: User
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                // Display Profile Picture (from albumImages or fallback to user image)
                if let albumImages = user.albumImages, let firstImageUrl = albumImages.first {
                    AsyncImage(url: URL(string: firstImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .shadow(radius: 4)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(Text("...").foregroundColor(.white))
                    }
                } else if let imageUrl = user.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .shadow(radius: 4)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(Text("...").foregroundColor(.white))
                    }
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.gray.opacity(0.4)))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                }

                // Display User Details
      
                    
            
                VStack(alignment: .leading, spacing: 5) {
                    HStack{
                    Text(user.username)
                        .font(.headline)
                        .foregroundColor(.white)
                        Spacer()

                    if let birthDate = parseISO8601Date(user.dateOfBirth) {
                        Text("\(birthDate)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("Birthdate unavailable")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                }
                

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(radius: 5)
        )
    }

    // MARK: - Helper to Parse ISO8601 Date
    private func parseISO8601Date(_ dateString: String) -> String? {
        if let date = dateFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date) // e.g., "Jan 5, 2025"
        }
        return nil
    }
}


struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                Text("Back")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
        }
    }
}
