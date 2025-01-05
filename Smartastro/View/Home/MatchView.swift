import SwiftUI

struct MatchView: View {
    let matchedUserName: String // Name of the matched user
    var onKeepSwiping: () -> Void // Callback for Keep Swiping action

    @State private var animateZodiac: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Match Text
                VStack {
                    Text("It's a Match!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                        .padding(.bottom, 8)

                    Text("You and \(matchedUserName) have liked each other.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Zodiac Signs Animation
                ZStack {
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 5
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(animateZodiac ? 360 : 0))
                            .offset(x: index == 0 ? -60 : 60, y: 0)
                            .animation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: false),
                                value: animateZodiac
                            )

                        Image(systemName: index == 0 ? "sun.max.fill" : "moon.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(index == 0 ? .yellow : .gray)
                            .offset(x: index == 0 ? -60 : 60, y: 0)
                            .rotationEffect(.degrees(animateZodiac ? 360 : 0))
                            .animation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: false),
                                value: animateZodiac
                            )
                    }
                }
                .onAppear {
                    animateZodiac = true
                }

                // Keep Swiping Button
                Button(action: onKeepSwiping) {
                    HStack {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                        Text("Keep Swiping")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    MatchView(matchedUserName: "Alyssa") {
        print("Keep Swiping tapped")
    }
}
