import SwiftUI

struct StoryView: View {
    var images: [String]
    @StateObject private var countTimer: CountTimer

    init(images: [String]) {
        self.images = images
        self._countTimer = StateObject(wrappedValue: CountTimer(items: images.count, interval: 4.0))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Display the current story image based on progress
                if let imageURL = URL(string: images[safe: Int(countTimer.progress)] ?? "") {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .edgesIgnoringSafeArea(.all)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                }

                // Loading Bars for Story Progress
                HStack(alignment: .center, spacing: 4) {
                    ForEach(images.indices, id: \.self) { index in
                        LoadingBar(progress: min(max(CGFloat(countTimer.progress) - CGFloat(index), 0.0), 1.0))
                            .frame(height: 2)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.4))

                // Tap Areas for Navigation
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            countTimer.advancePage(by: -1) // Go to the previous image
                        }
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            countTimer.advancePage(by: 1) // Go to the next image
                        }
                }
            }
            .onAppear { countTimer.start() }
            .onDisappear { countTimer.stop() }
        }
    }
}
