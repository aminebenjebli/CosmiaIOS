import SwiftUI
import CoreData

struct ContentView: View {
    // View Properties
    @State private var showSignup: Bool = false

    var body: some View {
        NavigationStack {
            Login(showSignup: $showSignup)
                .navigationDestination(isPresented: $showSignup) {
                    SignUp(showSignup: $showSignup) // Passing the showSignup binding to SignUp view
                }
        }
        .overlay {
            // Show the circle animation only in login/signup flow
                CircleView(showSignup: showSignup)
        }
    }
}

// Moving Blurred Background
@ViewBuilder
func CircleView(showSignup: Bool) -> some View {
    Circle()
        .fill(.linearGradient(colors: [.blue, .purple, .black], startPoint: .top, endPoint: .bottom))
        .frame(width: 200, height: 200)
        .offset(x: showSignup ? 90 : -90, y: -90)
        .blur(radius: 15)
        .hSpacing(showSignup ? .trailing : .leading)
        .vSpacing(.top)
        .animation(.smooth(duration: 0.45, extraBounce: 0), value: showSignup)
}

#Preview {
    ContentView()
}
