import SwiftUI

struct SwipeableAlbum: View {
    let user: User
    let onSwipedLeft: () -> Void
    let onSwipedRight: () -> Void

    @State private var offset = CGSize.zero
    @State private var isSwiping = false

    var body: some View {
        ZStack {
            // Display the user's album as a stack of photos
            if let albumImages = user.albumImages, !albumImages.isEmpty {
                ForEach(albumImages.indices.reversed(), id: \.self) { index in
                    let imageUrl = albumImages[index]
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 400)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .offset(x: CGFloat(index) * 10, y: CGFloat(index) * 10)
                    } placeholder: {
                        Color.gray
                            .frame(width: 300, height: 400)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .overlay(Text("Loading...").foregroundColor(.white))
                            .offset(x: CGFloat(index) * 10, y: CGFloat(index) * 10)
                    }
                }
            } else {
                // Fallback content if no album images
                Text("\(user.username)\n(\(user.zodiacSign))")
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(width: 300, height: 400)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    isSwiping = true
                }
                .onEnded { gesture in
                    if offset.width > 100 {
                        onSwipedRight()
                    } else if offset.width < -100 {
                        onSwipedLeft()
                    }
                    offset = .zero
                    isSwiping = false
                }
        )
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .animation(.spring(), value: offset)
    }
}
