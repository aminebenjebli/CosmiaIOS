import SwiftUI

struct CardStack: View {
    @StateObject private var viewModel = UserProfileViewModel(userId: "dummyId") // Initialize ViewModel

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
                // Display users in a swipeable stack
                ForEach(viewModel.users.indices.reversed(), id: \.self) { index in
                    let user = viewModel.users[index]
                    SwipeableCard(
                        content: "\(user.username)\n(\(user.zodiacSign))",
                        image: "person.circle", // Replace with user image if available
                        onSwipedLeft: {
                            print("Disliked: \(user.username)")
                            removeCard(at: index)
                        },
                        onSwipedRight: {
                            print("Liked: \(user.username)")
                            removeCard(at: index)
                        }
                    )
                    .zIndex(Double(index)) // Ensure cards are stacked
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchAllUsers()
        }
    }

    private func removeCard(at index: Int) {
        guard index >= 0 && index < viewModel.users.count else { return }
        viewModel.users.remove(at: index)
    }
}

#Preview {
    CardStack()
}
