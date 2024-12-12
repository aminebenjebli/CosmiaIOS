import SwiftUI

struct CardStack: View {
    @StateObject private var viewModel: UserProfileViewModel

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading users...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if viewModel.users.isEmpty {
                Text("No users available")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                ForEach(viewModel.users.indices.reversed(), id: \.self) { index in
                    let user = viewModel.users[index]

                    SwipeableCard(
                        content: "\(user.username)\n\(user.zodiacSign)",
                        albumImages: user.albumImages, // Pass album images here
                        onSwipedLeft: {
                            print("Disliked: \(user.username)")
                            removeCard(at: index)
                        },
                        onSwipedRight: {
                            handleLike(user: user, at: index)
                        }
                    )
                    .zIndex(Double(index)) // Ensure proper stacking
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchAllUsersWithAlbums() // Fetch users and their albums
        }
    }

    private func removeCard(at index: Int) {
        guard index >= 0 && index < viewModel.users.count else { return }
        viewModel.users.remove(at: index)
    }

    private func handleLike(user: User, at index: Int) {
        guard let likedUserId = user.id else {
            print("Error: Liked user ID is missing")
            return
        }

        print("[CardStack] Liking user with ViewModel.userId: \(viewModel.userId), LikedUserId: \(likedUserId)")
        viewModel.likeUser(userId: viewModel.userId, likedUserId: likedUserId) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print("Error liking user: \(error.localizedDescription)")
            }
        }
        removeCard(at: index)
    }
}
