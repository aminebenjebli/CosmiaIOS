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

    var body: some View {
        HStack(spacing: 15) {
            // User's Profile Picture
            if let imageUrl = user.albumImages?.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
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

            // Username and Details
            VStack(alignment: .leading, spacing: 5) {
                Text(user.username)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Click to chat")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer() // Push content to the left
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(radius: 5)
        )
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
