import SwiftUI

struct AlbumModalView: View {
    let albumImages: [String]
    @Environment(\.dismiss) var dismiss // Handle modal dismissal
    @State private var currentIndex = 0 // Track the current image

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background color

            if albumImages.isEmpty {
                Text("No Album Available")
                    .foregroundColor(.white)
                    .font(.headline)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(albumImages.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: albumImages[index])) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                        .tag(index) // Tag for TabView
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
