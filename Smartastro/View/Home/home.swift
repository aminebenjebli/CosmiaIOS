import SwiftUI

struct HomeView: View {
    @ObservedObject private var userSession = UserSession.shared // Observe UserSession for changes

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    // Ensure userId is updated correctly
                    if let currentUserId = userSession.userId, !currentUserId.isEmpty {
                        CardStack(userId: currentUserId) // Pass the userId to CardStack
                    } else {
                        Text("No user logged in.")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    
                    Spacer()
                    CustomBottomBar()
                        .padding(.bottom, 0) // Bottom navigation bar
                }
                .navigationTitle("Home")
                .padding(.horizontal)
            }
        }
    }
}


#Preview {
    HomeView()
}
