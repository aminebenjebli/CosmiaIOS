import SwiftUI

struct CustomBottomBar: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 70, style: .continuous) // Adjusted corner radius
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 70, style: .continuous) // Match corner radius
                        .stroke(Color.purple, lineWidth: 2)
                )
                .frame(height: 100)
                .edgesIgnoringSafeArea(.bottom) // Ignore the safe area to fully occupy the bottom
                .clipShape(
                    RoundedCornerShape(
                        topLeft: 30,
                        topRight: 30,
                        bottomLeft: 0,
                        bottomRight: 0
                    )
                ) // Add specific rounded corners

            HStack {
                // Group 1: Home and Feeds
                HStack(spacing: 30) {
                    // Home Button
                    Button(action: {
                        // Home button action
                    }) {
                        Image(systemName: "house.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    // Feeds Button
                    NavigationLink(destination: FeedsView()) {
                        Image(systemName: "newspaper.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }

                Spacer(minLength: 50) // Create space between groups

                // Camera Button (Center)
                Button(action: {
                    // Camera button action
                }) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        )
                }

                Spacer(minLength: 50) // Create space between groups

                // Group 2: Heart and Profile
                HStack(spacing: 30) {
                    // Heart Button
                    Button(action: {
                        // Heart button action
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    // Profile Button
                    NavigationLink(destination: UserProfile(userId: "sampleUserId")) {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 30)
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
