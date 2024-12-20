import SwiftUI

struct MatchedView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @State private var isLoading: Bool = false

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradientView()
                
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
            .onAppear {
                viewModel.fetchMatches()
            }
            .navigationTitle("Your Matches")
        }
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
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.users, id: \.id) { user in
                    NavigationLink(
                        destination: ChatView(
                            viewModel: ChatViewModel(),
                            receiverId: user.id ?? "",
                            receiverUsername: user.username // Pass the username to ChatView
                        )
                    ) {
                        MatchedUserView(user: user)
                    }
                }
            }
            .padding()
        }
    }
}

struct MatchedUserView: View {
    let user: User

    var body: some View {
        VStack {
            if let imageUrl = user.albumImages?.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
            }

            Text(user.username)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
