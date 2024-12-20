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
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                if viewModel.isLoading {
                    ProgressView("Loading matches...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.users.isEmpty {
                    Text("No matches found.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.users, id: \.id) { user in
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
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.fetchMatches()
            }
            .navigationTitle("Your Matches")
        }
    }
}
