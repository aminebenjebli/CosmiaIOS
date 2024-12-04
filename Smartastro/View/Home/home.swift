import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    CardStack() // Card stack integration
                    Spacer()
                    CustomBottomBar()
                        .padding(.bottom, 0)// Bottom navigation bar
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
