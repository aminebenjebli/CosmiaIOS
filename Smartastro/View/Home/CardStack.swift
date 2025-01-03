import SwiftUI

struct CardStack: View {
    @StateObject private var viewModel: UserProfileViewModel
    @State private var matchedUserName: String = "" // Store the matched user's name
    @State private var showMatchView = false // Flag to show the MatchView

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        VStack {
            // Filter Menu Button
            HStack {
                Button(action: {
                       viewModel.filterUsers(by: .genderMatch)
                   }) {
                       HStack {
                           Image(systemName: "person.fill")
                               .font(.title2)
                               .foregroundColor(.white)
                           Text("Gender")
                               .font(.body)
                               .foregroundColor(.white)
                       }
                       .padding(.leading, 20)
                   }
                Spacer()
                Menu {
                    Button(action: {
                        viewModel.filterUsers(by: .allUsers)
                    }) {
                        Label("All Users", systemImage: "globe")
                    }
                    Button(action: {
                        viewModel.filterUsers(by: .zodiacCompatibility)
                    }) {
                        Label("Zodiac Compatibility", systemImage: "star.fill")
                    }
                    Button(action: {
                        viewModel.filterUsers(by: .ageMatch)
                    }) {
                        Label("Same Zodiac Sign", systemImage: "person.crop.circle.fill")
                    }
                    Button(action: {
                        viewModel.filterUsers(by: .ageMatch)
                    }) {
                        Label("Same Age", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)
            }

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.users.isEmpty {
                    // Fetch users again when the stack is empty
                    Text("No users available")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .onAppear {
                            viewModel.fetchAllUsersWithAlbums()
                        }
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.fetchAllUsersWithAlbums() // Initial fetch
        }
        .sheet(isPresented: $showMatchView) {
            MatchView(
                matchedUserName: matchedUserName,
                onSendMessage: { print("Send Message tapped") },
                onKeepSwiping: { showMatchView = false }
            )
        }
    }

    private func removeCard(at index: Int) {
        guard index >= 0 && index < viewModel.users.count else { return }
        viewModel.users.remove(at: index)
        if viewModel.users.isEmpty {
            viewModel.fetchAllUsersWithAlbums() // Reload when the stack is empty
        }
    }

    private func handleLike(user: User, at index: Int) {
        guard let likedUserId = user.id else {
            print("Error: Liked user ID is missing")
            return
        }

        print("[CardStack] Liking user with ViewModel.userId: \(viewModel.userId), LikedUserId: \(likedUserId)")
        viewModel.likeUser(userId: viewModel.userId, likedUserId: likedUserId) { result in
            switch result {
            case .success(let matchedUser):
                if let matchedUser = matchedUser {
                    DispatchQueue.main.async {
                        matchedUserName = matchedUser.username
                        showMatchView = true
                    }
                    print("It's a match with \(matchedUser.username)!")
                } else {
                    print("User liked without a match.")
                }
            case .failure(let error):
                print("Error liking user: \(error.localizedDescription)")
            }
        }
        removeCard(at: index)
    }
}
