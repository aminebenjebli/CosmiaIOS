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
            .navigationBarBackButtonHidden(true) // Hide default back button
           
            }
            .navigationTitle("Your Matches")
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
                            receiverUsername: user.username
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
        VStack(spacing: 8) {
            if let imageUrl = user.albumImages?.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 5)
                } placeholder: {
                    ProgressView()
                        .frame(width: 120, height: 120)
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.gray.opacity(0.4)))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.indigo, lineWidth: 3))
                    .shadow(radius: 5)
            }

            Text(user.username)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
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
