import SwiftUI

struct CustomBottomBar: View {
    var body: some View {
        ZStack {
            // Background Bar
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(Color.white.opacity(0.95)) // Softer, lighter background
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10) // Stronger shadow for a floating effect
                .frame(height: 90)
                .edgesIgnoringSafeArea(.bottom)

            HStack {
                // Group 1: Home and Feeds
                HStack(spacing: 40) { // Reduced spacing for closer alignment
                    // Home Button
                    Button(action: {
                        // Home button action
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.purple)
                            Text("Home")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }

                    // Feeds Button
                    NavigationLink(destination: FeedsView()) {
                        VStack(spacing: 5) {
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                            Text("Feeds")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer(minLength: 70) // Adjusted spacer for better symmetry around the center button

                // Group 2: Likes and Profile
                HStack(spacing: 40) { // Reduced spacing for closer alignment
                    // Likes Button
                    NavigationLink(destination: MatchedView(userId: "sampleUserId")) {
                        VStack(spacing: 5) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                            Text("Likes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // Profile Button
                    NavigationLink(destination: UserProfile(userId: "sampleUserId")) {
                        VStack(spacing: 5) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                            Text("Profile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal, 20) // Reduced padding for compact layout


            // Floating Center Button
            Button(action: {
                // Camera button action
            }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 75, height: 75)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)

                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.8), Color.pink.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 5
                        )
                        .frame(width: 85, height: 85)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -40) // Offset to make it float above the bar
        }
    }
}

// Helper Shape for Specific Rounded Corners
struct RoundedCornerShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        return path
    }
}

#Preview {
    CustomBottomBar()
}
