import SwiftUI

struct MyImagesView: View {
    @StateObject var albumViewModel = AlbumViewModel()

    var body: some View {
        ZStack {
            // Purplish light gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Zodiac animation with rotating zodiac symbols
            ZodiacAnimationView()
                .opacity(0.3) // Light opacity to not overpower the content
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Title
                Text("My Album")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)

                // Loading Indicator
                if albumViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    // Scrollable image grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                            ForEach(albumViewModel.albumImages, id: \.self) { imageUrl in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Color.gray.opacity(0.3)
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(8)
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(8)
                                        case .failure:
                                            Color.red
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(8)
                                            Text("Failed to load")
                                                .foregroundColor(.white)
                                                .padding(5)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }

                                    // "X" button to delete image
                                    Button(action: {
                                        albumViewModel.deleteImage(imageUrl: imageUrl)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Error message
                if let errorMessage = albumViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .onAppear {
                albumViewModel.fetchAlbumImages()
            }
        }
    }
}

struct ZodiacAnimationView: View {
    @State private var rotation: Double = 0

    let zodiacSigns = [
        "♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"
    ]
    
    var body: some View {
        ZStack {
            // Rotating circle with zodiac signs
            ForEach(0..<zodiacSigns.count, id: \.self) { index in
                ZodiacSymbolView(symbol: zodiacSigns[index], size: 40, index: index)
                    .rotationEffect(.degrees(Double(index) * 30 + rotation))
                    .animation(Animation.linear(duration: 30).repeatForever(autoreverses: false), value: rotation)
            }
        }
        .onAppear {
            rotation = 360
        }
    }
}

struct ZodiacSymbolView: View {
    var symbol: String
    var size: CGFloat
    var index: Int

    var body: some View {
        Text(symbol)
            .font(.system(size: size))
            .foregroundColor(.red)
            .rotationEffect(.degrees(Double(index) * 30))
            .frame(width: size, height: size)
            .offset(x: 0, y: -150) // Adjust offset for circle radius
            .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: index)
    }
}

struct MyImagesView_Previews: PreviewProvider {
    static var previews: some View {
        MyImagesView()
    }
}
