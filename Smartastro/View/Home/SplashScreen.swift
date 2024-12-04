import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.7
    @State private var opacity: Double = 0.6
    @State private var shouldShowLogin = true // Default to showing login

    var body: some View {
        if isActive {
            if shouldShowLogin {
                ContentView() // Redirect to login
            } else {
                HomeView() // Redirect to home
            }
        } else {
            ZStack {
                // Starry Background Animation with Zodiac Symbols
                AstrologyBackground()
                    .edgesIgnoringSafeArea(.all)

                // Foreground Content
                VStack(spacing: 20) {
                    // Animated Logo
                    Image("logoCosmia")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .scaleEffect(logoScale)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                self.logoScale = 0.8
                            }
                            withAnimation(.easeIn(duration: 1.5)) {
                                self.opacity = 1.0
                            }
                        }
                }
            }
            .onAppear {
                checkSession()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Extended to 4 seconds
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }

    // MARK: - Session Validation
    private func checkSession() {
        guard let session = SessionManager.shared.getActiveSession() else {
            print("No active session found.")
            shouldShowLogin = true
            return
        }

        print("Active session found: \(session.userId ?? "Unknown")")
        shouldShowLogin = false
    }
}

struct AstrologyBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Animated Stars
            ForEach(0..<50) { _ in
                StarView()
            }

            // Subtle Purple Nebula Glow
            RadialGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.clear]),
                center: .center,
                startRadius: 10,
                endRadius: 500
            )
            .blendMode(.screen)

            // Rotating Zodiac Symbols
            ZodiacSymbols()
        }
        .onAppear {
            self.animate = true
        }
    }
}

struct StarView: View {
    @State private var xOffset: CGFloat = CGFloat.random(in: -200...200)
    @State private var yOffset: CGFloat = CGFloat.random(in: -400...400)
    @State private var opacity: Double = Double.random(in: 0.3...1.0)

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat.random(in: 3...5), height: CGFloat.random(in: 3...5))
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: Double.random(in: 6...12))
                        .repeatForever(autoreverses: false)
                ) {
                    self.xOffset = CGFloat.random(in: -200...200)
                    self.yOffset = CGFloat.random(in: -400...400)
                }
            }
    }
}

struct ZodiacSymbols: View {
    @State private var rotation: Double = 0.0

    let zodiacSigns = ["♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<zodiacSigns.count, id: \.self) { index in
                    Text(zodiacSigns[index])
                        .font(.system(size: 50)) // Increased size of zodiac symbols
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: -geometry.size.width / 2.5) // Adjusted radius for larger symbols
                        .rotationEffect(.degrees(Double(index) * 30))
                }
            }
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    self.rotation = 360
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
