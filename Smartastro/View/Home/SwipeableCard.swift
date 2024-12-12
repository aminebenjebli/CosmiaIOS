import SwiftUI

struct SwipeableCard: View {
    let content: String // User's name and zodiac sign
    let albumImages: [String]? // Album images for the user
    let onSwipedLeft: () -> Void
    let onSwipedRight: () -> Void

    @State private var offset = CGSize.zero
    @State private var showAlbumModal = false // State to show the album modal

    var body: some View {
        ZStack {
            // Background Image
            ZStack {
                if let albumImages = albumImages, let firstImageUrl = albumImages.first {
                    AsyncImage(url: URL(string: firstImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 400)
                            .cornerRadius(20)
                            .clipped()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(Text("Loading...").foregroundColor(.white))
                    }
                } else {
                    // Fallback if no album images are available
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Text("No Album").foregroundColor(.white))
                }
            }

            // Overlay Content
            VStack {
                    Spacer()

                            // User's Name and Zodiac Sign at the Bottom
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text(content)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cornerRadius(20)

                // Like and Dislike Buttons
                HStack {
                    Spacer()

                    VStack(spacing: 50) {
                        Button(action: {
                            withAnimation(.spring()) {
                                offset = CGSize(width: -500, height: 0) // Simulate swipe left
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipedLeft()
                                resetPosition()
                            }
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                        .font(.title)
                                )
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
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.green)
                                        .font(.title)
                                )
                        }
                    }
                    .padding(.trailing, 16)
                }
            }
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
        .onTapGesture {
            // Show the album modal on tap
            if let albumImages = albumImages, !albumImages.isEmpty {
                showAlbumModal = true
            }
        }
        .sheet(isPresented: $showAlbumModal) {
            AlbumModalView(albumImages: albumImages ?? [])
        }
    }

    private func resetPosition() {
        offset = .zero
    }
}
