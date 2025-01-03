import SwiftUI

struct HomeView: View {
    @ObservedObject private var userSession = UserSession.shared // Observe UserSession for changes
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Home Title
                    Text("Cosmia")
                        .font(.customfont(.regular, fontSize: 24))//Customfont
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 20)
                    
                    // Story Bar
                    StoryBar()
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
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
                        .padding(.bottom, 10)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HomeView()
}
