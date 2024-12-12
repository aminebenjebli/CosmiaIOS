import SwiftUI

struct HomeView: View {
    @ObservedObject private var userSession = UserSession.shared // Observe UserSession for changes
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Home Title
                    Text("Cosmia")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                        .padding(.top, 0)
                        
                    
                    // Story Bar
                    StoryBar()
                        .padding(.top, 0)// Spacing under the title
                    
                    Spacer()
                    
                    // Main Content
                    if let currentUserId = userSession.userId, !currentUserId.isEmpty {
                        CardStack(userId: currentUserId) // Pass the userId to CardStack
                    } else {
                        Text("No user logged in.")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Custom Bottom Navigation Bar
                    CustomBottomBar()
                        .padding(.bottom, 0)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HomeView()
}
