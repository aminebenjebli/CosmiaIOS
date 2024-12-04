import SwiftUI

struct SwipeableCard: View {
    let content: String // User's name
    let image: String // Image name or URL
    let onSwipedLeft: () -> Void
    let onSwipedRight: () -> Void

    @State private var offset = CGSize.zero
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)

            VStack {
                Spacer()

                // Image Section
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.purple, lineWidth: 4))
                    .padding()

                // User's Name
                Text(content)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Spacer()

                // Like and Dislike Buttons
                HStack(spacing: 50) { // Add spacing between buttons
                    Button(action: {
                        withAnimation(.spring()) {
                            offset = CGSize(width: -500, height: 0) // Simulate swipe left
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipedLeft()
                            resetPosition()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        withAnimation(.spring()) {
                            offset = CGSize(width: 500, height: 0) // Simulate swipe right
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipedRight()
                            resetPosition()
                        }
                    }) {
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, 16) // Add padding at the bottom
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 10)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width < -150 {
                        onSwipedLeft()
                    } else if offset.width > 150 {
                        onSwipedRight()
                    }
                    resetPosition()
                }
        )
        .animation(.spring(), value: offset)
    }

    private func resetPosition() {
        offset = .zero
    }
}
